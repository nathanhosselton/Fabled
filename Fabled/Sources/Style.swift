import UIKit.UIColor

/// Namespace for app-wide constants relating to UI styling and configuration.
enum Style {
    enum Font {
        /// The type family used for body text.
        static let body = UIFont.systemFont(ofSize: 16, weight: .regular).fontName //.SFUIText

        /// The type family used for heading text.
        static let heading = UIFont.systemFont(ofSize: 20, weight: .medium).fontName //.SFUIDisplay-Medium

        /// The type family used for title text.
        static let title = UIFont.systemFont(ofSize: 20, weight: .semibold).fontName //.SFUIDisplay-Semibold

        /// The type family used for **T H I C C** text.
        static let thicc = UIFont.systemFont(ofSize: 20, weight: .bold).fontName //.SFUIDisplay-Bold
    }

    enum Color {
        /// The background color to be used for views.
        static let background = UIColor.black
    }
}
