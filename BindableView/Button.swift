//
//  Button.swift
//  BindableViews
//
//  Created by Nathan Hosselton on 7/3/19.
//  Copyright © 2019 Nathan Hosselton. All rights reserved.
//

import UIKit.UIButton

/// A wrapper view for `UIButton` which provides a binding for responding to touch events.
///
/// Because subclasses of `UIButton` cannot make use of its (now standard) convenience
/// constructor `init(type:)`, we provide this wrapper view which installs the configured
/// `UIButton` as its subview.
final class Button: UIView, BindableControl {
    typealias ControlType = UIButton

    /// The binding provided by this view for responding to touch events on the underlying `UIButton`.
    ///
    /// - Note: `observe(:with:)` is the intended method for observing this control's events and must be
    ///  called at least once before touch event forwarding to this binding will begin.
    /// - Seealso: `observe(:with:)`
    let controlEventBinding = Binding<(sender: UIButton, event: UIEvent)>()

    /// The `UIButton` instance created and managed by this view.
    /// - Note: This accessor is provided for convenience. Direct manipulation of the `UIButton` is
    /// usually unnecessary and may interfere with its relationship to this parent view.
    /// - Important: Do not add the `UIButton` directly to your view hierarchy.
    let uiButton: UIButton

    /// The text to display in the `UIButton`'s label for the `.normal` control state.
    var title: String {
        didSet {
            uiButton.setTitle(title, for: .normal)
        }
    }

    /// The designated initializer for this class.
    ///
    /// Immediately constructs the underlying `UIButton` object and adds it to the view hierarchy for this
    /// view. Further configuration events on this object will continue to be forwarded to the `UIButton`;
    /// configuring it directly via the `uiButton` or `associatedControl` properties is not necessary. Events
    /// which update this view's frame will automatically update the bounds of the `UIButton` to match.
    ///
    /// - Parameters:
    ///     - type: The `ButtonType` to be used. The default is `.system`.
    ///     - title: The text to use for the button's title in the normal control state.
    init(type: UIButton.ButtonType = .system, _ title: String) {
        self.title = title
        self.uiButton = UIButton(type: type)

        super.init(frame: .zero)

        uiButton.setTitle(title, for: .normal)
        uiButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(uiButton)

        NSLayoutConstraint.activate([
            uiButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            uiButton.topAnchor.constraint(equalTo: topAnchor),
            uiButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            uiButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    init(_ image: UIImage) {
        self.title = ""
        self.uiButton = UIButton(type: .system)

        super.init(frame: .zero)

        uiButton.setImage(image, for: .normal)
        uiButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(uiButton)

        NSLayoutConstraint.activate([
            uiButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            uiButton.topAnchor.constraint(equalTo: topAnchor),
            uiButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            uiButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    /// Configure the button's title label for other states. May be called multiple times.
    /// - Parameters:
    ///   - text: The title to use for the label.
    ///   - state: A variadic list of control states when the title should be displayed. Defaults to
    ///     `.normal` when omitted.
    func title(_ text: String, while state: UIControl.State...) -> Self {
        let states = state.isEmpty ? [.normal] : state
        for state in states {
            switch state {
            case .normal: self.title = text
            default: uiButton.setTitle(text, for: state)
            }
        }
        return self
    }

    /// Configure the button's title label color for the provided state(s). May be called multiple times.
    /// - Parameters:
    ///   - color: The color to use for the title label's text.
    ///   - state: A variadic list of control states when the color should be used. Defaults to `.normal`
    ///     when omitted.
    func titleColor(_ color: UIColor, while state: UIControl.State...) -> Self {
        let states = state.isEmpty ? [.normal] : state
        for state in states {
            uiButton.setTitleColor(color, for: state)
        }
        return self
    }

    /// Set the font of the text displayed in the button's title label.
    /// - parameter font: The font to be used.
    /// - SeeAlso: `font(:)`
    func font(_ font: UIFont) -> Self {
        uiButton.titleLabel?.font = font
        return self
    }

    /// Set the font of the text displayed in the button's title label using the provided font name and
    /// preserving the current font size.
    /// - parameter name: The full name of the font to be used, e.g. `"HelveticaNeue-LightItalic"`.
    /// - SeeAlso: `font(:)`
    func font(_ name: String) -> Self {
        uiButton.titleLabel?.font = UIFont(name: name, size: uiButton.titleLabel?.font.pointSize ?? UIFont.systemFontSize)
        return self
    }

    /// Sets the font of the text displayed in the button's title label using a descriptor.
    /// - parameter descriptor: The descriptor to use for setting the font.
    func font(from descriptor: UIFontDescriptor) -> Self {
        uiButton.titleLabel?.font = UIFont(descriptor: descriptor, size: uiButton.titleLabel?.font.pointSize ?? UIFont.systemFontSize)
        return self
    }

    /// Sets the size of the current font of the button's title label.
    /// - parameter size: The size to use for the current font, in points.
    func fontSize(_ size: CGFloat) -> Self {
        uiButton.titleLabel?.font = uiButton.titleLabel?.font.withSize(size)
        return self
    }

    /// Sets the tint color for the UIButton object.
    /// - parameter color: The color to set for the tint.
    func tintColor(_ color: UIColor) -> Self {
        uiButton.tintColor = color
        return self
    }

    /// Sets the inset or outset margins for the rectangle surrounding all of the button’s content.
    /// - parameter insets: The insets to use.
    func contentEdgeInsets(_ insets: UIEdgeInsets) -> Self {
        uiButton.contentEdgeInsets = insets
        return self
    }

    func styleProvider(_ provider: (_ stylable: UIButton) -> Void) -> Self {
        provider(uiButton)
        return self
    }

    /// Sets the content hugging priority of the view and its enclosed UIButton.
    /// - Parameters:
    ///   - priority: The layout priority value to use.
    ///   - axis: Variadic list of the layout axes on which to set the priority. If not provided, defaults to all.
    func contentHuggingPriority(_ priority: UILayoutPriority, _ axis: NSLayoutConstraint.Axis...) -> Self {
        let axes = axis.isEmpty ? [.horizontal, .vertical] : axis
        axes.forEach {
            setContentHuggingPriority(priority, for: $0)
            uiButton.setContentHuggingPriority(priority, for: $0)
        }
        return self
    }

    /// Sets the content compression resistance priority of this view and its enclosed UIButton.
    /// - Parameters:
    ///   - priority: The layout priority value to use.
    ///   - axis: Variadic list of the layout axes on which to set the priority. If not provided, defaults to all.
    func contentCompressionResistance(_ priority: UILayoutPriority, _ axis: NSLayoutConstraint.Axis...) -> Self {
        let axes = axis.isEmpty ? [.horizontal, .vertical] : axis
        axes.forEach {
            setContentCompressionResistancePriority(priority, for: $0)
            uiButton.setContentCompressionResistancePriority(priority, for: $0)
        }
        return self
    }

    override var forFirstBaselineLayout: UIView {
        return uiButton.forFirstBaselineLayout
    }

    override var forLastBaselineLayout: UIView {
        return uiButton.forLastBaselineLayout
    }

    /// Adjusts the frame of this view and its enclosed `UIButton` automatically. Separately settng
    /// the `frame` of the `UIButton` is unsupported.
    override var frame: CGRect {
        didSet {
            uiButton.frame = .init(origin: .zero, size: bounds.size)
        }
    }

    /// Target selector for the `UIButton` instance's action, which emits the event through the `binding`.
    @objc private func onControlEvent(sender: UIButton, event: UIEvent) {
        controlEventBinding.emit((sender, event))
    }

    deinit {
        associatedControl.removeTarget(self, action: #selector(onControlEvent), for: .allEvents)

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
    override init(frame: CGRect) {
        fatalError("\(#file + #function) is not available.")
    }
}

extension Button {
    var associatedControl: UIButton {
        return uiButton
    }

    /// As `Button` does not have any sensible use for accepting an external binding, this property simply
    /// references the `controlEventBinding`.
    var binding: Binding<(sender: UIButton, event: UIEvent)>? {
        return controlEventBinding
    }

    func observe(_ event: UIControl.Event = .touchUpInside, with observer: @escaping () -> Void) -> Self {
        associatedControl.addTarget(self, action: #selector(onControlEvent), for: event)
        controlEventBinding.observe { _ in observer() }
        return self
    }

    func observe(_ event: UIControl.Event = .touchUpInside, with observer: @escaping (_ sender: UIButton) -> Void) -> Self {
        associatedControl.addTarget(self, action: #selector(onControlEvent), for: event)
        controlEventBinding.observe { (sender, _) in observer(sender) }
        return self
    }

    func observe(_ event: UIControl.Event = .touchUpInside, with observer: @escaping (_ e: UIEvent) -> Void) -> Self {
        associatedControl.addTarget(self, action: #selector(onControlEvent), for: event)
        controlEventBinding.observe { (_, event) in observer(event) }
        return self
    }

    func observe(_ event: UIControl.Event = .touchUpInside, with observer: @escaping (_ sender: UIButton, _ e: UIEvent) -> Void) -> Self {
        associatedControl.addTarget(self, action: #selector(onControlEvent), for: event)
        controlEventBinding.observe(with: observer)
        return self
    }
}
