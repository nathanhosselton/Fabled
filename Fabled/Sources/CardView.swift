import UIKit

/// Abstract base class for "card views" in the app. Subclasses must implement
/// `var body` and called `super.init()` within their custom initializer.
class CardView: UIView {
  var body: UIView {
    fatalError("\(type(of: self)) \(#function) must be overridden by the subclass")
  }

  required init(coder: NSCoder = .empty) {
    super.init(frame: .zero)

    //Rounded bg color for "card"
    let color = UIView()
    color.backgroundColor = UIColor(white: 1.0, alpha: 0.13)
    color.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    color.layer.cornerRadius = 10

    let body = self.body
    body.insertSubview(color, at: 0)

    //Need to pad leading/trailing space so `body` width is flexible but stays compressed
    let padder = StackView(.horizontal, [
      Spacer(.flexible),
      body,
      Spacer(.flexible)
    ])

    addSubview(padder)

    //Pin invisible padder to this view
    NSLayoutConstraint.activate([
      padder.topAnchor.constraint(equalTo: topAnchor),
      padder.trailingAnchor.constraint(equalTo: trailingAnchor),
      padder.bottomAnchor.constraint(equalTo: bottomAnchor),
      padder.leadingAnchor.constraint(equalTo: leadingAnchor),
    ])
  }
}

extension CardView {
  /// A collection of standard font related constants for `CardView`s.
  enum Font {
    static let titleSize: CGFloat = 60
    static let headingSize: CGFloat = 20
    static let bodySize: CGFloat = 15
  }
}
