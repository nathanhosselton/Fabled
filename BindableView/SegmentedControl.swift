//
//  SegmentedControl.swift
//  BindableViews
//
//  Created by Nathan Hosselton on 7/3/19.
//  Copyright © 2019 Nathan Hosselton. All rights reserved.
//

import UIKit.UISegmentedControl

/// A subclass of `UISegmentedControl` which accepts a `Binding` for tracking changes to its selection.
///
/// The value type of the binding provided is required to be a `CaseIterable` `enum` with an `Int`
/// `RawValue` and conforming to `CustomStringConvertible`. This allows `SegmentedControl` to
/// provide a concrete object upon selection (rather than an integer value) and to auto-populate
/// the segment names using the `description` property for each of the enum's cases.
final class SegmentedControl<T: RawRepresentable & CaseIterable & CustomStringConvertible>: UISegmentedControl, BindableControl where T.RawValue == Int {
    typealias ControlType = UISegmentedControl
    
    let controlEventBinding = Binding<(sender: UISegmentedControl, event: UIEvent)>()
    
    /// The value binding to this control's selection, updated upon selection change.
    private(set) weak var binding: Binding<T>?

    /// The designated initializer for this class. Takes a binding which is updated for each value change
    /// to this control's selection.
    /// - parameter updating: The value binding to the control's selection state.
    init(_ updating: Binding<T>) {
        self.binding = updating
        
        super.init(frame: .zero)

        // Unfortunately we can't use `.init(items:)` because it requires an override of `.init(frame:)`
        for (index, `case`) in T.allCases.enumerated() {
            insertSegment(withTitle: `case`.description, at: index, animated: false)
        }

        addTarget(self, action: #selector(selectionChanged), for: .valueChanged)
    }

    /// Sets the selected segment of the control.
    /// - parameter index: The index of the segment to set as the selected segment.
    func selectedSegment(_ index: Int) -> Self {
        self.selectedSegmentIndex = 0
        return self
    }

    /// Set the font of the text displayed in the segments.
    /// - parameter font: The font to be used.
    /// - SeeAlso: `font(named:)`
    func font(_ font: UIFont) -> Self {
        var attr = titleTextAttributes(for: .normal) ?? [:]
        attr[.font] = font
        UIControl.State.allCases.forEach { setTitleTextAttributes(attr, for: $0) }
        return self
    }

    /// Set the font of the text displayed in the segments using the provided font name and preserving the current font size.
    /// - parameter name: The full name of the font to be used, e.g. `"HelveticaNeue-LightItalic"`.
    /// - SeeAlso: `font(:)`
    func font(_ name: String) -> Self {
        var attr = titleTextAttributes(for: .normal) ?? [:]
        let size = (attr[.font] as? UIFont)?.pointSize ?? UIFont.preferredFont(forTextStyle: .body).pointSize
        attr[.font] = UIFont(name: name, size: size)
        UIControl.State.allCases.forEach { setTitleTextAttributes(attr, for: $0) }
        return self
    }

    /// Sets the font of the text displayed in the segments using a descriptor and preserving the current font size if not provided.
    /// - parameter descriptor: The descriptor to use for setting the font.
    func font(from descriptor: UIFontDescriptor) -> Self {
        var attr = titleTextAttributes(for: .normal) ?? [:]

        let size: CGFloat
        if descriptor.pointSize > 0 {
            size = descriptor.pointSize
        } else {
            size = (attr[.font] as? UIFont)?.pointSize ?? UIFont.preferredFont(forTextStyle: .body).pointSize
        }

        attr[.font] = UIFont(descriptor: descriptor, size: size)
        UIControl.State.allCases.forEach { setTitleTextAttributes(attr, for: $0) }

        return self
    }

    /// Sets the size of the font of the text displayed in the segments.
    /// - parameter size: The size to use for the current font, in points.
    func fontSize(_ size: CGFloat) -> Self {
        var attr = titleTextAttributes(for: .normal) ?? [:]
        attr[.font] = (attr[.font] as? UIFont)?.withSize(size) ?? UIFont.preferredFont(forTextStyle: .headline).withSize(size)
        UIControl.State.allCases.forEach { setTitleTextAttributes(attr, for: $0) }
        return self
    }

    /// Sets the color of the segment title text for the provided control state(s). May be called multiple times.
    /// - Parameters:
    ///   - color: The color to use for each segment's title text.
    ///   - state: A variadic list of control states when the color should be used. Defaults to `.normal`
    ///     when omitted.
    func titleColor(_ color: UIColor, while state: UIControl.State...) -> Self {
        let states = state.isEmpty ? [.normal] : state
        for state in states {
            var attr = titleTextAttributes(for: state) ?? [:]
            attr[.foregroundColor] = color
            setTitleTextAttributes(attr, for: state)
        }
        return self
    }

    func styleProvider(_ provider: (_ stylable: UISegmentedControl) -> Void) -> Self {
        provider(self)
        return self
    }

    @objc private func selectionChanged() {
        guard let selection = T.init(rawValue: selectedSegmentIndex)
            else { fatalError("index \(selectedSegmentIndex) is out of bounds for \(type(of: T.self))") }
        binding?.emit(selection)
    }

    @objc private func onControlEvent(sender: UISegmentedControl, event: UIEvent) {
        controlEventBinding.emit((sender, event))
    }

    deinit {
        removeTarget(self, action: #selector(selectionChanged), for: .valueChanged)
        removeTarget(self, action: #selector(onControlEvent), for: .allEvents)

        #if DEBUG
        print("\(type(of: self)) deinit")
        #endif
    }


    //MARK: Unavailable

    @available(*, unavailable)
    required init(coder: NSCoder = .empty) {
        fatalError("\(#file + #function) is not available.")
    }

    @available(*, unavailable)
    override init(items: [Any]?) {
        fatalError("\(#file + #function) is not available.")
    }

    @available(*, unavailable)
    override init(frame: CGRect) {
        fatalError("\(#file + #function) is not available.")
    }
}

extension SegmentedControl {
    var associatedControl: UISegmentedControl {
        return self
    }

    func observe(_ event: UIControl.Event, with observer: @escaping () -> Void) -> Self {
        associatedControl.addTarget(self, action: #selector(onControlEvent), for: event)
        controlEventBinding.observe { _ in observer() }
        return self
    }

    func observe(_ event: UIControl.Event, with observer: @escaping (_ sender: UISegmentedControl) -> Void) -> Self {
        associatedControl.addTarget(self, action: #selector(onControlEvent), for: event)
        controlEventBinding.observe { (sender, _) in observer(sender) }
        return self
    }

    func observe(_ event: UIControl.Event, with observer: @escaping (_ e: UIEvent) -> Void) -> Self {
        associatedControl.addTarget(self, action: #selector(onControlEvent), for: event)
        controlEventBinding.observe { (_, event) in observer(event) }
        return self
    }

    func observe(_ event: UIControl.Event, with observer: @escaping (_ sender: UISegmentedControl, _ e: UIEvent) -> Void) -> Self {
        associatedControl.addTarget(self, action: #selector(onControlEvent), for: event)
        controlEventBinding.observe(with: observer)
        return self
    }
}



extension UIControl.State {
    static var allCases: [UIControl.State] {
        return [.normal, .highlighted, .disabled, .selected, .focused]
    }
}
