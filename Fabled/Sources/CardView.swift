import UIKit

/// Abstract base class for "card views" in the app. Subclasses must implement
/// `var body` and called `super.init()` within their custom initializer.
class CardView: UIView {
    var body: UIView {
        fatalError("\(type(of: self)) \(#function) must be overridden by the subclass")
    }

    required init(coder: NSCoder = .empty) {
        super.init(frame: .zero)

        layer.cornerRadius = DisplayScale.x375.scale(30)
        backgroundColor = Style.Color.cardView

        let body = self.body
        let inset = Style.Layout.largeSpacing

        addSubview(body)

        NSLayoutConstraint.activate([
            body.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            body.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
            body.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset),
            body.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset)
        ])
    }

    /// Styling provider for the primary value text of `CardView`s (the large numbers).
    func primaryValueTextStyling(_ label: UILabel) {
        label.font = Style.Font.thicc.withSize(CardView.Font.titleSize)
        label.textColor = Style.Color.text
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.widthAnchor.constraint(greaterThanOrEqualToConstant: CardView.Spacing.minimumTitleWidth).isActive = true
    }

    /// Styling provider for the header text of `CardView`s.
    func headerTextStyling(_ label: UILabel) {
        label.font = Style.Font.heading.withSize(CardView.Font.headingSize)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.76
        label.textColor = Style.Color.text
    }

    /// Styling provider for the body text of `CardView`s.
    func bodyTextStyling(_ label: UILabel) {
        label.font = Style.Font.body.withSize(CardView.Font.bodySize)
        label.textColor = Style.Color.text
    }
}

//MARK: CardView Styling

extension CardView {
    /// A collection of standard font related constants for text inside `CardView`s.
    enum Font {
        static let titleSize: CGFloat = DisplayScale.x375.scale(60)
        static let headingSize: CGFloat = DisplayScale.x375.scale(22)
        static let bodySize: CGFloat = DisplayScale.x375.scale(16)
    }

    /// A collection of spacing related constants for subview layout inside `CardView`s.
    enum Spacing {
        static let title: CGFloat = Style.Layout.largeSpacing
        static let heading: CGFloat = 6
        static let body: CGFloat = 4

        /// The minimum value for width of the primary value column of card views.
        static let minimumTitleWidth: CGFloat = DisplayScale.x375.scale(76)
    }
}
