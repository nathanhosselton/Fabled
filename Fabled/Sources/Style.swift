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
        /// The background color to be used for the window and root views.
        static let background = UIColor.black

        /// The color for content which which may be interactive but should be de-emphasized.
        static let deemphasized = UIColor.lightGray

        /// The color for interactive content which has been disabled.
        static let disabled = UIColor.darkGray

        /// The color for content which is interactive and enabled.
        static let interactive = UIColor.white

        /// The color to be used for neutral text.
        static let text = UIColor.white

        /// The color to be used for text of crucial note to the user.
        static let imperativeText = UIColor.red

        /// The background color to be used for `CardView`s.
        static let cardView = UIColor(white: 0.133, alpha: 1.0)//UIColor(white: 1.0, alpha: 0.13)

        /// The color to be used for standard "pill" views.
        static let pill = UIColor(white: 0.133, alpha: 1.0)

        /// The color to be used for emphasized "pill" views.
        static let emphasizedPill = UIColor.red
    }
}
