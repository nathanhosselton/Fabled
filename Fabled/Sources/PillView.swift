import UIKit

/// A view wrapper with a pill-shaped visual appearance.
final class PillView: UIView {

    /// Type representing the available display styles for `PillView`s.
    enum DisplayStyle {
        /// Provides a muted background color for the view.
        case plain
        /// Provides an attention-drawing background color for the view.
        case emphasized

        /// Returns the background color for a specific display style.
        var color: UIColor {
            switch self {
            case .plain: return Style.Color.pill
            case .emphasized: return Style.Color.emphasizedPill
            }
        }
    }

    /// Returns a pill-shaped view of the given style and with the provided view added as a subview.
    /// - Parameters:
    ///   - style: The visual `DisplayStyle` the pill view should have.
    ///   - body: The view which should be wrapped by the pill view.
    init(_ style: DisplayStyle, _ body: UIView) {
        super.init(frame: .zero)

        backgroundColor = style.color

        translatesAutoresizingMaskIntoConstraints = false
        body.translatesAutoresizingMaskIntoConstraints = false

        addSubview(body)

        let yInset: CGFloat = DisplayScale.x375.scale(8)
        let xInset: CGFloat = yInset * 2.333

        NSLayoutConstraint.activate([
            body.topAnchor.constraint(equalTo: topAnchor, constant: yInset),
            body.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -xInset),
            body.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -yInset),
            body.leadingAnchor.constraint(equalTo: leadingAnchor, constant: xInset)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }

    @available(*, unavailable)
    required init(coder: NSCoder = .empty) {
        fatalError("init(coder:) has not been implemented")
    }
}
