//
//  DeclarativeView.swift
//  BindableViews
//
//  Created by Nathan Hosselton on 8/23/19.
//  Copyright © 2019 Nathan Hosselton. All rights reserved.
//

import UIKit.UIView

/// An protocol to be adopted by any `UIView`, providing declarative access to common methods
/// and property setters.
///
/// This protocol is inherited by `BindableView` and `BindableControl`.
protocol DeclarativeView: UIView, CustomStyleProvidable
{}

extension DeclarativeView {

    /// Sets the background color of the view.
    /// - parameter color: The color to set for the view's background.
    func backgroundColor(_ color: UIColor) -> Self {
        backgroundColor = color
        return self
    }

    /// Sets the opactiy of the view's background color.
    /// - parameter value: The opacity amount where `1.0` is fully opaque and `0.0` is transparent.
    /// - precondition: You must set your desired  `backgroundColor` before calling this method.
    func backgroundOpactiy(_ value: CGFloat) -> Self {
        backgroundColor = backgroundColor?.withAlphaComponent(value)
        return self
    }

    /// Sets the tint color of the view.
    /// - parameter color: The color to set for the view's tint.
    func tintColor(_ color: UIColor) -> Self {
        tintColor = color
        return self
    }

    /// Sets the alpha value of the view.
    /// - parameter value: The amount to set for the view's alpha.
    func alpha(_ value: CGFloat) -> Self {
        alpha = value
        return self
    }

    /// Sets the content hugging priority of the view.
    /// - Parameters:
    ///   - priority: The layout priority value to use.
    ///   - axis: Variadic list of the layout axes on which to set the priority. If not provided, defaults to all.
    func contentHuggingPriority(_ priority: UILayoutPriority, _ axis: NSLayoutConstraint.Axis...) -> Self {
        let axes = axis.isEmpty ? [.horizontal, .vertical] : axis
        axes.forEach { setContentHuggingPriority(priority, for: $0) }
        return self
    }

    /// Sets the content compression resistance priority of the view.
    /// - Parameters:
    ///   - priority: The layout priority value to use.
    ///   - axis: Variadic list of the layout axes on which to set the priority. If not provided, defaults to all.
    func contentCompressionResistance(_ priority: UILayoutPriority, _ axis: NSLayoutConstraint.Axis...) -> Self {
        let axes = axis.isEmpty ? [.horizontal, .vertical] : axis
        axes.forEach { setContentCompressionResistancePriority(priority, for: $0) }
        return self
    }

    /// Assigns a width constraint to the view and immediately acitivates it.
    /// - parameter constant: The value for the constraint.
    func width(_ constant: CGFloat) -> Self {
        widthAnchor.constraint(equalToConstant: constant).isActive = true
        return self
    }

    /// Assigns a height constraint to the view and immediately acitivates it.
    /// - parameter constant: The value for the constraint.
    func height(_ constant: CGFloat) -> Self {
        heightAnchor.constraint(equalToConstant: constant).isActive = true
        return self
    }

    /// Assigns a height and width constraint to the view and immediately acitivates it.
    /// - parameter constant: The value for the constraint.
    func size(_ constant: CGFloat) -> Self {
        _ = width(constant)
        return height(constant)
    }

    /// Offset the view by the specified amount on an axis.
    /// - Important: This method applies a transform. Actual constraint and frame values are unchanged.
    /// - Parameters:
    ///     - axis: The axis on which to perform the offset.
    ///     - amount: The amount to offset the view from its origin. Negative values reduce relative positioning.
    func offset(_ axis: NSLayoutConstraint.Axis, _ amount: CGFloat) -> Self {
        let x: CGFloat
        let y: CGFloat

        switch axis {
        case .vertical:
            x = 0.0; y = amount
        case .horizontal:
            x = amount; y = 0.0
        @unknown default:
            return self
        }

        transform = transform.translatedBy(x: x, y: y)

        return self
    }

    /// Set this view's `isHidden` property.
    /// - parameter now: The value to set for the view's `isHidden` property.
    /// - Seealso: isHidden(:when::)
    func isHidden(_ now: Bool) -> Self {
        isHidden = now
        return self
    }


    /// Configures the view to automaticaly adjust its appearance to rest just above the keyboard when
    /// presented, then return to its original position when the keyboard is dismissed.
    ///
    /// This method invokes a translation transform directly to the view. It does not alter constraint or frame
    /// values. As such, it is recommened that the method be called on the view which contains all content
    /// you wish to adjust (such as a stack view).
    ///
    /// A negative `offset` value may be provided to exclude any content that you do not mind being
    /// obscured by the keyboard.
    ///
    /// This method will additionally animate in a full-screen, semi-opaque view just behind this view when
    /// `obscureOtherContent` is set. This obscuring view will contain a tap gesture recognizer that will call
    /// `endEdtiting(:)` on this view when triggered, dismissing the keyboard when the text field is a subview.
    ///
    /// - Note: Though the obscuring view is full-screen, its hit detection is still limited to the frame of its
    /// superview (which is this view's superview). This is intended behavior of UIKit.
    /// - Parameters:
    ///     - enable: Pass `false` to disable this functionality if previously enabled.
    ///     - offset: An offset amount to apply to the distance between the bottom of this view and the top of the
    ///     keyboard. Pass a negative value to "inset" the keyboard over this view.
    ///     - obscureOtherContent: Pass `true` to also obscure other content behind this view.
    func adjustsForKeyboard(_ enable: Bool = true, offset: CGFloat = 0.0, obscureOtherContent: Bool = false) -> Self {
        guard enable else {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
            return self
        }

        //Configure obscuring view if set
        var contentObscuringView: ObscureView?
        if obscureOtherContent {
            contentObscuringView = ObscureView()
            contentObscuringView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.endEditing)))
        }

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { [weak self] note in
            guard let self = self, let superview = self.superview, let window = UIApplication.shared.keyWindow else { return }

            //Calculate distance
            let viewBottom = window.convert(self.frame, to: window).maxY + 16.0 + offset
            let kbTop = (note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.origin.y ?? 0
            let distance = min(kbTop - viewBottom, 0)

            guard distance < 0 else { return }

            //Obscure background content if set
            if let contentObscuringView = contentObscuringView {
                contentObscuringView.frame = window.convert(window.frame, to: superview)
                superview.insertSubview(contentObscuringView, belowSubview: self)
            }

            UIView.animate(withDuration: 0.3) {
                self.transform = self.transform.translatedBy(x: 0, y: distance)
                contentObscuringView?.alpha = 1.0
            }
        }

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { [weak self] note in
            UIView.animate(withDuration: 0.3, animations: {
                self?.transform = .identity
                contentObscuringView?.alpha = 0.0
            }, completion: { _ in
                contentObscuringView?.removeFromSuperview()
            })
        }
        return self
    }
}

/// Defines a single configurator method which, when adopted by a `BindableView`, provides a means of
/// making more extensive customization changes to the view separate from its declarative API.
///
/// `DeclarativeView` adopts this protocol and is subsequently inherited by its anscestors.
protocol CustomStyleProvidable: class {

    /// The type of the view object being provided for styling. Typically, the `BindableView`'s base UIKit
    /// class, or the `associatedControl`'s class in the case of a `BindableControl`.
    associatedtype Stylable: UIView

    /// A convenience method for providing additional arbitrary configuration of the view separate from
    /// the declarative API. This method may be called multiple times.
    ///
    /// The provided function is executed immediately by the receiver which passes in either itself or its
    /// relevant associated view or control for configuration by the caller. This is useful when:
    ///   - The desired configuration is not available through the view's declarative API
    ///   - The configuration is verbose or needlessly distracting at the declaration site
    ///   - The configuration is shared across multiple views and should be consolidated
    ///
    /// A named function is the expected means of supplying this method's parameter.
    ///
    /// - Parameters:
    ///   - provider: The function to receive the view object. A named function is recommended.
    ///   - stylable: The view object to be configured.
    func styleProvider(_ provider: (_ stylable: Stylable) -> Void) -> Self
}

/// Custom view object for obscuring background content in `DeclarativeView.adjustsForKeyboard(:offset:obscureOtherContent:)`.
private class ObscureView: UIView {
    required init(coder aDecoder: NSCoder = .empty) {
        super.init(frame: .zero)
        backgroundColor = UIColor(white: 0.0, alpha: 0.866)
        alpha = 0.0
    }
}
