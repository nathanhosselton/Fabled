//
//  BindableView.swift
//  BindableViews
//
//  Created by Nathan Hosselton on 7/10/19.
//  Copyright © 2019 Nathan Hosselton. All rights reserved.
//

import UIKit.UIView

/// A protocol representing a view object that accepts updates from and/or itself updates a provided `Binding`
/// based on user input.
///
/// The single conformance requirment is the presense of a `binding` property. It is up to the view to decide
/// its own implementation using that binding. For instance, a conforming `UILabel` would only observe
/// its binding, using it to update its `text` property, while a conforming `UITextField` would post updates
/// to its binding based on its input from the user.
///
/// Default implementations of methods for arbitrary transformations using bindings are also provided.
protocol BindableView: DeclarativeView {
    associatedtype BindingValue

    /// The binding accepted by this view at initialization which communicates updates to this view.
    ///
    /// `BindableView`s are not expected to create or otherwise own the bindings they use. As such,
    /// this property is weakly retained. It is the responsibility of the controller of this view to create
    /// and retain the `State` that manages the binding.
    var binding: Binding<BindingValue>? { get }
}

extension BindableView {

    /// Sets the initial value for display by the view via its binding.
    /// - Important: _All_ observers of the binding will receive this update.
    /// - parameter value: The value for the view to initially display.
    func startingValue(_ value: BindingValue) -> Self {
        binding?.emit(value)
        return self
    }

    /// Performs the provided transform to this view when the condition is met.
    ///
    /// Observes the provided binding, checking its value when updated and conditionally executing the
    /// provided transform. Useful where there are conditional states on the view that cannot be
    /// updated via its primary `binding`, such as changing a color or font value.
    ///
    /// - Important: The provided binding is not retained, but the transform _is_. Do not
    ///     pass methods without proper consideration for retain cycles.
    ///
    /// - Parameters:
    ///   - binding: The boolean value binding to observe for executing the transform.
    ///   - is: Optional comparitor for the `binding`'s value. Defaults to `true`.
    ///   - transform: A function which passes in `self` for arbitrary updates.
    ///   - self: This view object.
    func transforming(when binding: Binding<Bool>, is: Bool = true, _ transform: @escaping (_ self: Self) -> ()) -> Self {
        binding.observe { [weak self] in
            if $0 == `is`, let self = self {
                transform(self)
            }
        }
        return self
    }

    /// Performs the provided transform to this view when the binding is updated.
    ///
    /// Observes the provided binding and executes the provided transform when it updates,
    /// passing in the new value and this view for arbitrary changes. Useful where there are
    /// conditional states on the view that cannot be updated via its primary `binding`,
    /// such as changing a color or font value.
    ///
    /// - Important: The provided binding is not retained, but the transform _is_. Do not
    ///     pass methods without proper consideration for retain cycles.
    ///
    /// - Parameters:
    ///   - binding: The value binding to observe for executing the transform.
    ///   - transform: A function which passes in the new value and `self` for arbitrary updates.
    ///   - value: The new binding value.
    ///   - self: This view object.
    func transforming<T>(when binding: Binding<T>, _ transform: @escaping (_ value: T, _ self: Self) -> Void) -> Self {
        binding.observe { [weak self] in
            guard let self = self else { return }
            transform($0, self)
        }
        return self
    }

    /// Allows for a binding to automatically manage the view's `isHidden` state.
    ///
    /// The provided binding will be observed by this view and its value used to toggle the visibility of the
    /// view any time the binding is updated.
    ///
    ///     Label("Thanks!")
    ///       .isHidden(while: userHasAgreedToTerms.binding, is: false)
    ///     // Label will be hidden initally and whenever `result` gets an empty string; visible otherwise.
    ///
    /// - Parameters:
    ///     - initially: The initial value to set for the view's `isHidden` property. The default value is `false`.
    ///     - binding: The binding to be observed for updating the view's visibility.
    ///     - is: An optional toggle to the logic of the provided binding. Defaults to `true`.
    ///
    /// - Returns: `self` for declarative-style chaining.
    /// - Note: The provided binding is _not_ retained by the view.
    /// - Seealso: isHidden(:when::)
    func isHidden(while binding: Binding<Bool>, is: Bool = true) -> Self {
        binding.observe { [weak self] value in
            self?.isHidden = value == `is`
        }
        return self
    }

    /// Allows for a binding to automatically manage the view's `isHidden` state.
    ///
    /// The provided binding will be observed by this view, applying the closure as a transform to its value
    /// and using the result to toggle the visibility of this view any time the binding's value is changed.
    ///
    ///     Label("Result: ")
    ///       .isHidden(true, when: result.binding) { $0.isEmpty }
    ///     // Label will be hidden initally and whenever `result` gets an empty string; visible otherwise.
    ///
    /// - Parameters:
    ///     - now: The initial value to set for the view's `isHidden` property. The default value is `false`.
    ///     - binding: The binding to be observed for updating the view's visibility.
    ///     - logic: The closure to use for determining the view's visibility based on the binding's value changes.
    ///     - next: The value of the binding, as it changes.
    ///
    /// - Returns: `self` for declarative-style chaining.
    /// - Note: The provided binding is _not_ retained by the view.
    /// - Seealso: isHidden(initially:when:is:)
    func isHidden<T>(_ now: Bool = false, when binding: Binding<T>, _ logic: @escaping (T) -> Bool) -> Self {
        isHidden = now
        binding.observe { [weak self] value in
            self?.isHidden = logic(value)
        }
        return self
    }

    /// Allows for a binding to automatically manage the view's `isHidden` state.
    ///
    /// This is a convenience variant which expects a binding tracking an array of `State`s, typically generated using
    /// `State.combined(:)`. Each state object's value `snapshot` will be fed into the provided closure each time that any
    /// individual state object is updated, allowing validation of multiple fields.
    ///
    ///     Label("Result: ")
    ///       .isHidden(true, when: results.binding, allSatisfy: { !$0.isEmpty })
    ///     // Label will be hidden initally and whenever any value in `results` gets an empty string; visible otherwise.
    ///
    /// - Parameters:
    ///     - now: The initial value to set for the view's `isHidden` property. The default value is `false`.
    ///     - combined: The binding of `State`s to be observed for updating the view's visibility.
    ///     - logic: The closure to use for determining the view's visibility based on the binding's value changes.
    ///     - next: The value `snapshot` of each state object from the binding, as it changes.
    ///
    /// - Returns: `self` for declarative-style chaining.
    /// - Note: The provided binding is _not_ retained by the view.
    /// - Seealso: isHidden(:when::)
    func isHidden<T, U>(_ now: Bool = false, when combined: Binding<[T]>, allSatisfy logic: @escaping (_ next: U) -> Bool) -> Self where T: State<U> {
        isHidden = now
        combined.observe { [weak self] (values) in
            self?.isHidden = values.allSatisfy { logic($0.snapshot) }
        }
        return self
    }
}



/// A protocol representing a control object that provides a `Binding` for responding to its target-action events.
///
/// Because `UIControl`s are sometimes arduous to effectively subclass, conformers are not themselves expected
/// to be a `UIControl`. Instead, a conforming view is merely expected to provide an instance of its relevant
/// `UIControl` object via the required `associatedControl` property, which may return `self` for conformers which
/// _are_ a `UIControl`.
///
/// Conformance provides default implementations of common `UIControl` functions, such as managing the control's
/// enabled state and responding to action events.
protocol BindableControl: BindableView {

    /// The base UIKit class of a conformer's `associatedControl` .
    associatedtype ControlType: UIControl

    /// The concrete `UIControl` object managed by the conforming `BindableControl` type.
    var associatedControl: ControlType { get }

    /// The binding provided by this control for responding to target-action events.
    ///
    /// In most cases, a conforming `BindableControl` type will provide an API for automatically handling
    /// events for the most common usage of that control (e.g. text changes in `TextField`). This binding
    /// and its associated methods are provided for specialized configuration, or for those control types
    /// for which accepting an external value-binding would have no functional meaning (e.g. `UIButton`).
    ///
    /// - Note: `observe(:with:)` is the intended method for observing this control's events and must be
    ///  called at least once before event forwarding to this binding will begin.
    /// - Seealso: `observe(:with:)`
    var controlEventBinding: Binding<(sender: ControlType, event: UIEvent)> { get }

    /// Observe this control's binding with the provided function, which will receive the specified events.
    ///
    /// Calling this method or its variants multiple times to respond to different events or with different
    /// handlers is supported. However, because `Binding` does not support discrete removal of its
    /// observers, removing all target-actions from the `associatedControl` is the only way to
    /// discontinue delivery of events.
    /// - Parameters:
    ///     - event: The desired `UIControl.Event` to observe.
    ///     - observer: The function used to observe events.
    func observe(_ event: UIControl.Event, with observer: @escaping () -> Void) -> Self

    /// Observe this control's binding with the provided function, which will receive the specified events.
    ///
    /// Calling this method or its variants multiple times to respond to different events or with different
    /// handlers is supported. However, because `Binding` does not support discrete removal of
    /// observers, removing all target-actions from the `associatedControl` is the only way to
    /// discontinue delivery of events.
    /// - Parameters:
    ///     - event: The desired `UIControl.Event` to observe.
    ///     - observer: The function used to observe events.
    ///     - sender: A reference to the control object which sent the event.
    func observe(_ event: UIControl.Event, with observer: @escaping (_ sender: ControlType) -> Void) -> Self

    /// Observe this control's binding with the provided function, which will receive the specified events.
    ///
    /// Calling this method or its variants multiple times to respond to different events or with different
    /// handlers is supported. However, because `Binding` does not support discrete removal of
    /// observers, removing all target-actions from the `associatedControl` is the only way to
    /// discontinue delivery of events.
    /// - Parameters:
    ///     - event: The desired `UIControl.Event` to observe.
    ///     - observer: The function used to observe events.
    ///     - e: The specific event which occurred.
    func observe(_ event: UIControl.Event, with observer: @escaping (_ e: UIEvent) -> Void) -> Self

    /// Observe this control's binding with the provided function, which will receive the specified events.
    ///
    /// Calling this method or its variants multiple times to respond to different events or with different
    /// handlers is supported. However, because `Binding` does not support discrete removal of
    /// observers, removing all target-actions from the `associatedControl` is the only way to
    /// discontinue delivery of events.
    /// - Parameters:
    ///     - event: The desired `UIControl.Event` to observe.
    ///     - observer: The function used to observe events.
    ///     - sender: A reference to the control object which sent the event.
    ///     - e: The specific event which occurred.
    func observe(_ event: UIControl.Event, with observer: @escaping (_ sender: ControlType, _ e: UIEvent) -> Void) -> Self
}

extension BindableControl {

    /// Set this control's `isEnabled` property.
    /// - parameter now: The value to set for the control's `isEnabled` property.
    /// - Seealso: isEnabled(:when::)
    func isEnabled(_ now: Bool) -> Self {
        associatedControl.isEnabled = now
        return self
    }

    /// Allows for a binding to automatically manage the control's `isEnabled` state.
    ///
    /// The provided binding will be observed by this view, applying the closure as a transform to its value
    /// and using the result to toggle the enabled state of this control any time the binding's value is changed.
    ///
    ///     Button("Done")
    ///         .isEnabled(when: result.binding) { !$0.isEmpty }
    ///     // Button will be disabled initally and whenever `result` gets an empty string; enabled otherwise.
    ///
    /// - Parameters:
    ///     - now: The initial value to set for the control's `isEnabled` property. The default value is `false`.
    ///     - binding: The binding to be observed for updating the control's enabled state.
    ///     - logic: The closure to use for determining the control's enabled state based on the binding's value changes.
    ///     - next: The value of the binding, as it changes.
    ///
    /// - Returns: `self` for declarative-style chaining.
    /// - Note: The provided binding is _not_ retained by the control.
    /// - Seealso: isEnabled(:)
    func isEnabled<T>(_ now: Bool = false, when binding: Binding<T>, _ logic: @escaping (_ next: T) -> Bool) -> Self {
        associatedControl.isEnabled = now
        binding.observe { [weak self] value in
            self?.associatedControl.isEnabled = logic(value)
        }
        return self
    }

    /// Allows for a binding to automatically manage the control's `isEnabled` state.
    ///
    /// This is a convenience variant which expects a binding tracking an array of `State`s, typically generated using
    /// `State.combined(:)`. Each state object's value `snapshot` will be fed into the provided closure each time that any
    /// individual state object is updated, allowing validation of multiple fields.
    ///
    ///     Button("Done")
    ///         .isEnabled(when: results.binding, allSatisfy: { !$0.isEmpty })
    ///     // Button will be disabled initally and whenever any value in `results` gets an empty string; enabled otherwise.
    ///
    /// - Parameters:
    ///     - now: The initial value to set for the control's `isEnabled` property. The default value is `false`.
    ///     - combined: The binding of `State`s to be observed for updating the control's enabled state.
    ///     - logic: The closure to use for determining the control's enabled state based on the binding's value changes.
    ///     - next: The value `snapshot` of each state object from the binding, as it changes.
    ///
    /// - Returns: `self` for declarative-style chaining.
    /// - Note: The provided binding is _not_ retained by the control.
    /// - Seealso: isEnabled(:when::)
    func isEnabled<T, U>(_ now: Bool = false, when combined: Binding<[T]>, allSatisfy logic: @escaping (_ next: U) -> Bool) -> Self where T: State<U> {
        associatedControl.isEnabled = now
        combined.observe { [weak self] (values) in
            self?.associatedControl.isEnabled = values.allSatisfy { logic($0.snapshot) }
        }
        return self
    }
}
