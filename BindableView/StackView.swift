//
//  StackView.swift
//  BindableViews
//
//  Created by Nathan Hosselton on 7/2/19.
//  Copyright © 2019 Nathan Hosselton. All rights reserved.
//

import UIKit.UIStackView

public typealias Spacer = StackView.Spacer

public class StackView: UIStackView, DeclarativeView {

    /// A view which represents spacing between `StackView`'s arranged subviews.
    ///
    /// `Spacer` is a concrete UIView instance which is added to your stack view's hierarchy when
    /// placed inside of the `arrangedSubview` list given to your `StackView` at initialization.
    /// However, instances of `Spacer` are transparent and so are not visible in your UI.
    ///
    /// `Spacer`s come in two varieties: flexible and static. A static spacer has a predefined
    /// value for its size which is constant. A static spacer's size is governed by a size constraint
    /// assigned to the view at the axis corresponding to that of the stack view's.
    ///
    /// In contrast, a flexible spacer has no constant size. Instead, a flexible spacer will attempt
    /// to stretch its stack view to its maximum size, splitting this extra spacing evenly across any
    /// other flexible spacers present within the stack view. As such, usage of a flexible spacer
    /// requires that the stack view has a constrained size limit on its axis.
    ///
    /// See the documentation on the initializers for more information.
    public final class Spacer: UIView {
        public enum FlexibleNamespacer { case flexible }

        /// Initializes a spacer with flexible size that adapts to the size of the containing stack view
        /// and splits its height evenly across any sibling flexible spacers in the stack view.
        ///
        /// A flexible spacer will always attempt to fill remaining space within the stack view's
        /// maximum allowable size based on its constraints.
        ///
        /// For instance, a flexible spacer placed at the top of a stack view will force its content
        /// to the bottom of the view. An additional flexible spacer placed at the end will center the
        /// stack view's visible content. A third placed in the middle will split the content and visually
        /// center them within each's respective half of the view.
        ///
        /// Use of flexible spacers requires that the stack view has a constrained size limit on its
        /// axis either explicitly (height/width), or implicitly (pinned to neighboring views).
        ///
        /// - parameter _: The namespacer. Provide `.flexible`.
        public init(_: FlexibleNamespacer) {
            super.init(frame: .zero)
            tag = UIView.FlexibleSpacerTag
            backgroundColor = .clear
            translatesAutoresizingMaskIntoConstraints = false
        }

        /// Initializes a static spacer at the provided constant size. Passing a value of zero or less
        /// or omitting the value will instead return a flexible spacer.
        ///
        /// The spacer view will maintain the specified size via a constraint on the axis corresponding
        /// to the containing stack view's axis. So: a width constraint for horizontal stack views, and a
        /// height constraint for vertical.
        ///
        /// - parameter size: The desired size for the spacer.
        public convenience init(_ size: CGFloat = 0) {
            self.init(.flexible)

            guard size > 0 else { return }

            frame.size = CGSize(width: size, height: size)
            tag = UIView.StaticSpacerTag
        }

        /// The size of this spacer.
        var size: CGFloat {
            set {
                for constraint in constraints {
                    constraint.constant = newValue
                }
            }
            get { return max(frame.size.width, frame.size.height) }
        }

        fileprivate func setAxis(_ axis: NSLayoutConstraint.Axis) {
            switch (tag, axis) {
            case (UIView.FlexibleSpacerTag, _):
                setContentHuggingPriority(.defaultLow, for: axis)
                setContentCompressionResistancePriority(.defaultLow, for: axis)
            case (UIView.StaticSpacerTag, .vertical):
                heightAnchor.constraint(equalToConstant: size).isActive = true
            case (UIView.StaticSpacerTag, .horizontal):
                widthAnchor.constraint(equalToConstant: size).isActive = true
            case (_, _):
                return
            }
        }

        fileprivate func withAxis(_ axis: NSLayoutConstraint.Axis) -> Self {
            setAxis(axis)
            return self
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    }

    /// The designated initializer. Adds provided views and `Spacer`s to the stack view's arranged subviews,
    /// aligning to the specified `axis`.
    ///
    /// `StackView` defines its subview spacing via instances of the `Spacer` view class. You should add
    ///  these directly to your `arrangedSubviews` list at the position and size where you would like custom
    ///  spacing. To add general spacing to your stack view in positions where custom spacing was not defined,
    ///  use the `defaultSpacing(:)` configurator.
    ///
    /// - Parameters:
    ///   - axis: The axis on which this stack view should lay out its views.
    ///   - arrangedSubviews: The views and `Spacer`s to add to the stack view's hierarchy.
    ///
    /// - Seealso: `defaultSpacing(:)`
    required init(_ axis: NSLayoutConstraint.Axis, _ arrangedSubviews: [UIView]) {
        super.init(frame: .zero)

        self.axis = axis
        self.translatesAutoresizingMaskIntoConstraints = false

        //Note: We could conditionally support UIStackView's iOS 11 custom spacing API, treating
        //instances of Spacer instead as abstract indicators of where custom spacing should be
        //placed within the stack view instead of adding them to the hierarchy. However, this
        //would complicate our implementation significantly, and I'm unsure the benefits of
        //doing so would even be tangible. Apple's implementation is undoubtedly more performant,
        //but to what degree? Enough to make up for our selective usage? Safety would be the
        //main reason to leverage it. Still, using the custom spacing API for the flexible spacers
        //would necessitate grabbing the content sizes from layoutSubviews and updating the custom
        //spacing each pass. Our solution is undoutedbly more ideal, as it allows the stack view
        //to govern the heights. So do we use our solution for the flexible spacers and Apple's
        //for the static ones? That would lead to even more complicated code and, worst of all,
        //render our own implementation inconsistent. So I've chosen to not support the iOS 11
        //API at all. All spacing is set via our transparent Spacer views, even spacing added by
        //our general `spacing` function. This way, our implementation is both simple and consistent.
        //If issues arise in the future, I will revist.

        var lastFlexibleSpacer: UIView?
        for view in arrangedSubviews {
            addArrangedSubview(view)

            if let spacer = view as? Spacer {
                spacer.setAxis(axis)
            }

            if view.isFlexibleSpacer {
                //Ensure flexible spacers share the spacing along the axis.
                if let last = lastFlexibleSpacer {
                    switch axis {
                    case .vertical:
                        view.heightAnchor.constraint(equalTo: last.heightAnchor).isActive = true
                    case .horizontal:
                        view.widthAnchor.constraint(equalTo: last.widthAnchor).isActive = true
                    @unknown default: break
                    }
                }
                lastFlexibleSpacer = view
            }
        }
    }

    /// Sets spacing between any two arranged subviews which do not already have spacing.
    /// Specifying a value of zero or less has no effect.
    ///
    /// `StackView` spacing is implemented exclusively via `Spacer` objects which are
    /// inserted into the stack view's arranged subview hierarchy. Thus, this method does _not_
    /// set the `spacing` property of the stack view (which remains at `0`).
    ///
    /// When adding spacing between views, this method skips any views which had spacing
    /// previously defined by `Spacer`s added at the stack view's initialization.
    ///
    /// - parameter spacing: The amount of spacing to set between views.
    ///
    /// - Seealso: `StackView.Spacer`
    func defaultSpacing(_ spacing: CGFloat) -> Self {
        guard spacing > 0 else { return self }

        let subviews = arrangedSubviews
        var offset = 0
        for (position, subview) in subviews.enumerated() where !subview.isSpacer {
            guard position > 0 else { continue }

            if subviews[position - 1].isSpacer == false {
                insertArrangedSubview(Spacer(spacing).withAxis(axis), at: position + offset)
                offset += 1
            }
        }

        return self
    }

    /// Enables decreasing or increasing of the size of spacers added to this stack view relative to
    /// the provided display scale. This method immediately updates the current spacing size when called.
    /// - parameter scale: The display scale to use for scaling spacers. That is, the display scale
    ///   for which the spacer size will remain unchanged.
    func adjustsSpacingRelativeToDisplay(_ scale: DisplayScale) -> Self {
        for case let spacer as Spacer in arrangedSubviews {
            if spacer.isStaticSpacer {
                spacer.size = scale.scale(spacer.size)
            }
        }

        return self
    }

    /// Sets the `distribution` property of this stack view.
    /// - parameter distribution: The desired distribution for the stack view's arrangement.
    func distribution(_ distribution: UIStackView.Distribution) -> Self {
        self.distribution = distribution
        return self
    }

    /// Sets the `alignment` property of this stack view.
    ///
    /// As a convenience, this method additionally sets the `textAlignment` of any
    /// `UITextField` or `UILabel` instances within the stack view's arranged subviews
    /// (non-recursively) when `preservingSubviews` is `false`..
    ///
    /// - Parameters:
    ///   - alignment: The desired alignment for the stack view's arrangement.
    ///   - preservingSubviews: When `true`, subview alignment is not updated to
    ///   match. The default is `false`
    func alignment(_ alignment: UIStackView.Alignment, preservingSubviews: Bool = false) -> Self {
        self.alignment = alignment

        if !preservingSubviews {
            for case let view as UITextField in arrangedSubviews {
                view.textAlignment = alignment.textAlignment
            }

            for case let view as UILabel in arrangedSubviews {
                view.textAlignment = alignment.textAlignment
            }
        }

        return self
    }

    /// Sets the content hugging priority of the stack view.
    /// - Parameters:
    ///   - priority: The layout priority value to use.
    ///   - axis: The layout axis on which to set the priority. Defaults to the stack view's axis.
    func contentHuggingPriority(_ priority: UILayoutPriority, _ axis: NSLayoutConstraint.Axis...) -> Self {
        let axes = axis.isEmpty ? [self.axis] : axis
        axes.forEach { setContentHuggingPriority(priority, for: $0) }
        return self
    }

    /// Sets the content compression resistance priority of the stack view.
    /// - Parameters:
    ///   - priority: The layout priority value to use.
    ///   - axis: The layout axis on which to set the priority. Defaults to the stack view's axis.
    func contentCompressionResistance(_ priority: UILayoutPriority, _ axis: NSLayoutConstraint.Axis...) -> Self {
        let axes = axis.isEmpty ? [self.axis] : axis
        axes.forEach { setContentCompressionResistancePriority(priority, for: $0) }
        return self
    }

    func styleProvider(_ provider: (_ stylable: UIStackView) -> Void) -> Self {
        provider(self)
        return self
    }

    /// The temporary view used to obscure background content when a keyboard is presented.
    private weak var contentObscuringView: UIView?


    //MARK: Unavailable

    @available(*, unavailable)
    required init(coder: NSCoder = .empty) {
        fatalError("\(#file + #function) is not available.")
    }

//    @available(*, unavailable)
//    override init(frame: CGRect) {
//        fatalError("\(#file + #function) is not available.")
//    }
}


extension UIStackView.Alignment {
    var textAlignment: NSTextAlignment {
        switch self {
        case .leading: return .left
        case .center: return .center
        case .trailing: return .right
        default: return .natural
        }
    }
}


extension UIView {
    fileprivate static var FlexibleSpacerTag: Int {
        return #function.hashValue
    }

    fileprivate static var StaticSpacerTag: Int {
        return #function.hashValue
    }

    fileprivate var isSpacer: Bool {
        return isStaticSpacer || isFlexibleSpacer
    }

    fileprivate var isStaticSpacer: Bool {
        return tag == UIView.StaticSpacerTag
    }

    fileprivate var isFlexibleSpacer: Bool {
        return tag == UIView.FlexibleSpacerTag
    }
}
