//
//  State.swift
//  https://github.com/nathanhosselton/State
//
//  Copyright 2019, Nathan Hosselton; nathanhosselton@gmail.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be included
//  in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation

/// A type representing living (non-final) state in a view, most often that which is user-driven. Use instances
/// of `State` rather than raw values to clearly define the state within your app and create a single pipeline
/// for performing and observing mutations.
///
/// Once initialized, a `State` object's value can no longer be modified directly. Instead, `State` automatically
/// creates an associated `Binding` object which it observes to internally mutate its tracked value. This binding
/// can then be provided to any owner or displayer needing to change or listen for changes to the value.
///
/// `State` is most effectively used as wrappers of properties within the views they originate and are best
/// declared as `let` constants. Do not redefine `State` for additional views which also need access.
/// Instead, provide them with only the existing state object's `binding`.
public final class State<Value> {

    /// The binding created by this state for observing and sending changes to the value over time.
    public let binding: Binding<Value>

    /// Creates a new `State` object using the provided initial value.
    /// - parameter initialValue: The value that this object should begin with. If `nil`, the `Value`'s type
    /// will need to be explicitly defined at the declaration site.
    public init(initialValue: Value) {
        _value = initialValue
        binding = Binding<Value>()

        binding.observe { [weak self] (next) in
            self?._value = next
        }
    }

    /// The most recent update to this state's value, as received by its `binding`.
    ///
    /// The value returned is not fit for display to the user as it represents only a momentary view of the state.
    /// Instead, displayers of this `State`'s value should use the `binding` to listen for _all_ changes. Use this
    /// accessor only for final operations e.g. when the user has confirmed they have completed input.
    public var snapshot: Value {
        return _value
    }

    /// Immediately emits the state's current `snapshot` through its `binding`, notifying all observers.
    public func broadcast() {
        binding.emit(_value)
    }

    /// The internal storage for the value tracked by this `State`.
    private var _value: Value
}

public extension State {
    /// Creates and returns a new `State` object with the provided array of states as its value, listening for
    /// changes to each. When a change to any individual state occurs, this state re-emits all states it tracks.
    ///
    /// Use `combined` when you need a consolidated observer of multiple states, but don't need to know
    /// which specific state was updated, such as validation of multiple text fields.
    ///
    ///     let textFieldText1 = State(initialValue: "")
    ///     let textFieldText2 = State(initialValue: "")
    ///     // … (Text field changes linked to state)
    ///     let fieldTexts = State.combined([textFieldText1, textFieldText2])
    ///
    ///     fieldTexts.binding.observe { texts in
    ///         // Button enabled state is evaluated on every field change.
    ///         doneButton.isEnabled = texts.allSatisfy({ !$0.isEmpty })
    ///     }
    ///
    /// - parameter states: The array of pre-existing `State` objects which the returned state should track.
    static func combined(_ states: [State<Value>]) -> State<[State<Value>]> {
        let combined = State<[State<Value>]>(initialValue: states)

        for state in states {
            state.binding.observe { [weak combined] _ in
                guard let combined = combined else { return }
                combined.binding.emit(combined._value)
            }
        }

        return combined
    }
}



/// A thread-safe class that facilitates observations of a value over time.
///
/// A `Binding` does not retain the values given to it; it is merely a notification provider. When arbitrary access
/// to a binding's last value is needed, use `State`, which creates and manages a binding on your behalf.
/// - Seealso: `State`
public final class Binding<Value> {

    /// Creates a new binding. If an initial value is provided with one or more observers,
    /// the observers will receive that value.
    ///
    /// Typically, you will initialize a binding without these parameters. They are provided
    /// for convenience for scenarious such as branching responsibility from an existing binding.
    ///
    /// - Parameters:
    ///   - value: An initial value for this binding to be received by any provided observers. This value
    ///     is **not** retained. Providing an initial value with no observers has no effect.
    ///   - observers: One or more functions to be called when changes to the observed value occur.
    ///   - next: The value of this binding over time.
    public init(value: Value? = .none, _ observers: (_ next: Value) -> Void...) {
        self.observers = observers

        if let value = value, !observers.isEmpty {
            emit(value)
        }
    }

    /// Observe changes to this binding's value.
    /// - SeeAlso: map(_ transform:)
    ///
    /// - Parameters:
    ///   - observer: A function to be called when changes to the observed value occur.
    ///   - next: The value of this binding over time.
    ///
    /// - Note: The provided closure is internally retained. Be cognizant of passing strong references.
    ///
    /// - Note: As of Swift 5.0, closures that escape to other modules are copied to the heap (a 10x performance hit).
    ///   See: [this article](https://www.cocoawithlove.com/blog/2016/06/02/threads-and-mutexes.html).
    public func observe(with observer: @escaping (_ next: Value) -> Void) {
        mutex.sync {
            observers.append(observer)
        }
    }

    /// Notifies all observers of this binding with the provided value.
    ///
    /// - parameter next: The value to send to observers.
    public func emit(_ next: Value) {
        mutex.sync {
            observers.forEach { $0(next) }
        }
    }


    //MARK: Transforms

    /// Returns a new binding that emits the result of the provided transform.
    /// - SeeAlso: observe(with:)
    ///
    /// - Parameters:
    ///   - transform: The function used to update the new binding.
    ///   - next: The value of this binding over time.
    ///
    /// - Note: Because `binding`s do not retain the state they track, the value of the transform cannot be
    ///   verified as new when called and thus observers of the returned binding can receive updates where
    ///   the value is unchanged.
    public func map<T>(_ transform: @escaping (_ next: Value) -> T) -> Binding<T> {
        let branch = Binding<T>()

        observe { [weak branch] (value) in
            guard let binding = branch else { return }
            binding.emit(transform(value))
        }

        return branch
    }

    /// Returns a new binding that emits the sequenced result of applying the given transform to each element in this binding's sequence.
    /// - SeeAlso: map(_:)
    ///
    /// - Parameters:
    ///   - transform: The function used to update the new binding.
    ///   - next: The value of each element in this binding's sequence over time.
    public func flatMap<U>(_ transform: @escaping (_ next: Value.Element) -> U) -> Binding<[U]> where Value: Sequence {
        return map {
            $0.map(transform)
        }
    }

    /// Returns a new binding that emits the first value in this binding's sequence to satisfy the given predicate over time.
    ///
    /// - Parameters:
    ///   - predicate: The function used to identify the target value from this binding's sequence.
    ///   - element: The value of each element in this binding's sequence over time.
    public func first<T>(where predicate: @escaping (_ element: Value.Element) -> Bool) -> Binding<T?> where Value: Sequence, T == Value.Element {
        return map {
            $0.first(where: predicate)
        }
    }

    /// Flatten's this binding's optional value by sending the provided default value when unwrapping would result in `nil`.
    ///
    /// - Parameters:
    ///   - defaultValue: The value to be used when the result of unwrapping this binding's value is `nil`.
    public func unwrapped<U>(defaultValue: U) -> Binding<U> where Value == Optional<U> {
        return map {
            switch $0 {
            case .some(let value): return value
            case .none: return defaultValue
            }
        }
    }

    public func removeAllObservers() {
        observers.removeAll()
    }


    //MARK: Properties

    /// The current number of observers of this binding.
    public var observerCount: Int {
        return observers.count
    }

    /// The observers of this binding.
    fileprivate var observers: [(Value) -> Void]

    /// The queue onto which all of this binding's mutations and notifications are synchronized.
    fileprivate let mutex = DispatchQueue(label: "dev.NathanHosselton.State.Binding.queue")
}
