import UIKit.UIColor

/// Namespace for app-wide constants relating to UI styling and configuration.
enum Style {
    enum Font {
        static let NeueHaasGrotesk65Medium = "NHaasGroteskDSW02-65Md"
        static let NeueHaasGrotesk55Regular = "NHaasGroteskDSW02-55Rg"

        /// The base type family used for standard text.
        static let text = NeueHaasGrotesk55Regular

        static var standardFontDescriptor: UIFontDescriptor {
            var attr: [UIFontDescriptor.AttributeName : Any] = [:]
            attr[.name] = NeueHaasGrotesk55Regular
            attr[.traits] = [UIFontDescriptor.TraitKey.slant: NSNumber(floatLiteral: 1.0)]
            return UIFontDescriptor(fontAttributes: attr)
        }

        static let minimumScaleFactor: CGFloat = 0.666
    }

    enum Color {
        /// The background color to be used for views.
        static let background = UIColor.black
    }
}
