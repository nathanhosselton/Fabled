//
//  TextField.swift
//  BindableViews
//
//  Created by Nathan Hosselton on 7/2/19.
//  Copyright © 2019 Nathan Hosselton. All rights reserved.
//

import UIKit.UITextField

/// A subclass of `UITextField` which accepts a `Binding` for tracking changes to its text.
final class TextField: UITextField, BindableView, BindableControl {

    typealias ControlType = UITextField

    /// The value binding to this field's text, updated upon text change.
    private(set) weak var binding: Binding<String>?

    let controlEventBinding = Binding<(sender: UITextField, event: UIEvent)>()

    /// The designated initializer for this class. Takes a binding which is updated for each value change to this field's text.
    /// - parameter updating: The value binding to the field's text.
    init(_ updating: Binding<String>) {
        self.binding = updating
        super.init(frame: .zero)
        addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }

    /// Activates rate limiting at the specified interval for updates sent to the text field's `binding`.
    ///
    /// Use this method to avoid receiving updates from the text field about text changes until the provided
    /// time interval has passed since the last text change was made. For example, providing a value of `1`
    /// will prevent this field's `binding` from receiving an update until at least 1 second has elapsed since
    /// the user stopped typing, at which point the current `text` value of the field will be emitted.
    ///
    /// - parameter interval: The time interval at which updates should be rate limited.
    func updatesRateLimited(to interval: TimeInterval) -> Self {
        rateLimit = interval
        return self
    }

    /// Sets the placeholder text of the field.
    /// - parameter text: The text to be displayed in the field's placeholder.
    func placeholder(_ text: String) -> Self {
        self.placeholder = text
        return self
    }

    /// Set the font of the text displayed in the field.
    /// - parameter font: The font to be used.
    /// - SeeAlso: `font(_ name:)`
    func font(_ font: UIFont) -> Self {
        self.font = font
        return self
    }

    /// Set the font of the text displayed in the field using the provided font name and preserving the current font size.
    /// - parameter name: The full name of the font to be used, e.g. `"HelveticaNeue-LightItalic"`.
    /// - SeeAlso: `font(_ font:)`
    func font(_ name: String) -> Self {
        font = UIFont(name: name, size: font?.pointSize ?? UIFont.preferredFont(forTextStyle: .body).pointSize)
        return self
    }

    /// Sets the font of the text displayed in the field using a descriptor.
    /// - parameter descriptor: The descriptor to use for setting the font.
    func font(from descriptor: UIFontDescriptor) -> Self {
        let size: CGFloat
        if descriptor.pointSize > 0 {
            size = descriptor.pointSize
        } else {
            size = font?.pointSize ?? UIFont.preferredFont(forTextStyle: .body).pointSize
        }
        font = UIFont(descriptor: descriptor, size: size)
        return self
    }

    /// Sets the size of the current font.
    /// - parameter size: The size to use for the current font, in points.
    func fontSize(_ size: CGFloat) -> Self {
        font = font?.withSize(size)
        return self
    }

    /// Sets the color of typed text displayed in the field.
    /// - parameter color: The color to be used for the typed text.
    func textColor(_ color: UIColor) -> Self {
        textColor = color
        return self
    }

    /// Sets the color of placeholder text displayed in the field.
    /// - parameter color: The color to be used for the placeholder text.
    func placeholderColor(_ color: UIColor) -> Self {
        guard let text = placeholder else { fatalError("Placeholder color set before placeholder text. This will be lost.") }
        attributedPlaceholder = NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor: color])
        return self
    }

    /// Sets the color of cursor displayed in the field.
    /// - parameter color: The color to be used for the cursor.
    func cursorColor(_ color: UIColor) -> Self {
        tintColor = color
        return self
    }

    /// Sets the alignment of the text within the field.
    /// - parameter alignment: The alignment to be used.
    func textAlignment(_ alignment: NSTextAlignment) -> Self {
        textAlignment = alignment
        return self
    }

    /// Sets the keyboard type to be displayed when entering text into the field.
    /// - parameter type: The keyboard type to be used.
    func keyboardType(_ type: UIKeyboardType) -> Self {
        self.keyboardType = type
        return self
    }

    /// Sets the auto-capitalization style for the field.
    /// - parameter type: The auto-capitalization type to use.
    func autocapitalizationType(_ type: UITextAutocapitalizationType) -> Self {
        autocapitalizationType = type
        return self
    }

    /// Sets the autocorrection style for the field.
    /// - parameter type: The autocorrection type to use.
    func autocorrectionType(_ type: UITextAutocorrectionType) -> Self {
        autocorrectionType = type
        return self
    }

    /// Sets the left view of the field, optionally settings its view mode as well.
    /// - Parameters:
    ///   - view: The view to set.
    ///   - mode: The view mode to use for displaying the view.
    func leftView(_ view: UIView, mode: UITextField.ViewMode? = nil) -> Self {
        leftView = view
        if let mode = mode {
            leftViewMode = mode
        }
        return self
    }

    /// Sets the right view of the field, optionally settings its view mode as well.
    /// - Parameters:
    ///   - view: The view to set.
    ///   - mode: The view mode to use for displaying the view.
    func rightView(_ view: UIView, mode: UITextField.ViewMode? = nil) -> Self {
        rightView = view
        if let mode = mode {
            rightViewMode = mode
        }
        return self
    }

    /// Configures a target-action for the field that ends editing when the return key is pressed. Removes
    /// the target-action when `false` is passed.
    /// - parameter value: Provide `false` to disable this functionality after being enabled.
    func endEditingOnReturn(_ value: Bool = true) -> Self {
        if value {
            addTarget(self, action: #selector(endEditing), for: .editingDidEndOnExit)
        } else {
            removeTarget(self, action: #selector(endEditing), for: .editingDidEndOnExit)
        }
        return self
    }

    func styleProvider(_ provider: (_ stylable: UITextField) -> Void) -> Self {
        provider(self)
        return self
    }

    @objc private func textDidChange() {
        guard rateLimit > 0 else { return sendUpdate() }
        rateLimitTimer?.invalidate()
        rateLimitTimer = .scheduledTimer(timeInterval: rateLimit,
                      target: self,
                      selector: #selector(sendUpdate),
                      userInfo: nil,
                      repeats: false)
    }

    @objc private func sendUpdate() {
        binding?.emit(self.text ?? "")
    }

    @objc private func onControlEvent(sender: UITextField, event: UIEvent) {
        controlEventBinding.emit((sender, event))
    }

    private var rateLimit: TimeInterval = 0
    private var rateLimitTimer: Timer?

    override var placeholder: String? {
        set {
            guard attributedPlaceholder != nil else { return super.placeholder = newValue }
            //iOS <13.0 does not automatically update the `attributedPlaceholder`, so we are
            let placeholderColor = attributedPlaceholder?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor
            attributedPlaceholder = NSAttributedString(string: newValue ?? "", attributes: [NSAttributedString.Key.foregroundColor: placeholderColor ?? .darkText])
        }
        get { return super.placeholder }
    }

    deinit {
        removeTarget(self, action: #selector(textDidChange), for: .editingChanged)
        removeTarget(self, action: #selector(onControlEvent), for: .allEvents)

        #if DEBUG
        //FIXME: TextField has an internal retain cycle. UPDATE: Only iOS 13?
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

extension TextField {
    var associatedControl: UITextField {
        return self
    }

    func observe(_ event: UIControl.Event, with observer: @escaping () -> Void) -> Self {
        associatedControl.addTarget(self, action: #selector(onControlEvent), for: event)
        controlEventBinding.observe { _ in observer() }
        return self
    }

    func observe(_ event: UIControl.Event, with observer: @escaping (_ sender: UITextField) -> Void) -> Self {
        associatedControl.addTarget(self, action: #selector(onControlEvent), for: event)
        controlEventBinding.observe { (sender, _) in observer(sender) }
        return self
    }

    func observe(_ event: UIControl.Event, with observer: @escaping (_ e: UIEvent) -> Void) -> Self {
        associatedControl.addTarget(self, action: #selector(onControlEvent), for: event)
        controlEventBinding.observe { (_, event) in observer(event) }
        return self
    }

    func observe(_ event: UIControl.Event, with observer: @escaping (_ sender: UITextField, _ e: UIEvent) -> Void) -> Self {
        associatedControl.addTarget(self, action: #selector(onControlEvent), for: event)
        controlEventBinding.observe(with: observer)
        return self
    }
}
