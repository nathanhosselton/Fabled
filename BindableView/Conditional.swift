import UIKit.UIView

/// A faux view class that, rather than itself appearing in the view hierarchy, provides a logic interface for
/// hiding/showing views within its superview's hierarchy, flipping states using a boolean value binding.
///
/// This interface may be used to raise conditional view-appearance logic into the root declaration scope,
/// thereby mimicing actual conditional statements and making declarative view code more readable.
///
/// Under the hood, this class is simply flipping the `isHidden` state on provided views, relying on the
/// built-in functionality of UIStackViews to update layout automatically.
final class If: UIView {
    private(set) weak var binding: Binding<Bool>?

    /// Initializes using the provided binding which is to be observed for management of views
    /// passed to its `then` and `else` methods.
    ///
    /// The resulting object is inert until at least one of its logical methods is called with view objects.
    /// - Note: This view is expected to be added to a UIStackView or subclass. Adding to any other
    /// view object is unsupported.
    /// - parameter binding: The binding to observe for view display changes. Weakly retained.
    /// - Seealso: `then(:)`, `else(:)`
    init(_ binding: Binding<Bool>) {
        self.binding = binding
        super.init(frame: .zero)
    }

    /// Displays the provided views when the binding is `true` and hides them when the binding is `false`.
    ///
    /// Views passed to this method are added to the hierarchy of the parent UIStackView in the order
    /// they are provided.
    /// - parameter show: A varadic list of view objects to hide and show.
    /// - Seealso: `else(:)`
    func then(_ show: UIView...) -> Self {
        binding?.observe { [weak self] in
            for (position, view) in show.enumerated() {
                if view.superview == nil, let self = self, let stack = self.stackView {
                    stack.insertArrangedSubview(view, at: stack.arrangedSubviews.firstIndex(of: self)! + position)
                }
                view.isHidden = !$0
            }
        }

        return self
    }

    /// Displays the provided views when the binding emits is `false` and hides them when the binding is `true`.
    ///
    /// Views passed to this method are added to the hierarchy of the parent UIStackView in the order
    /// they are provided.
    /// - parameter show: A varadic list of view objects to hide and show.
    /// - Seealso: `then(:)`
    func `else`(_ show: UIView...) -> Self {
        binding?.observe { [weak self] in
            for (position, view) in show.enumerated() {
                if view.superview == nil, let self = self, let stack = self.stackView {
                    stack.insertArrangedSubview(view, at: stack.arrangedSubviews.firstIndex(of: self)! + position)
                }
                view.isHidden = $0
            }
        }

        return self
    }

    #if DEBUG
    override func didMoveToSuperview() {
        if let superview = superview, stackView == nil {
            print("""
                Warning: BindableView.If instance added to superview \(type(of: superview)) instead of expected \
                superview UIStackView. Views passed to `then` or `else` will never appear.
                """)
        }
    }
    #endif

    private var stackView: UIStackView? {
        return superview as? UIStackView
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
