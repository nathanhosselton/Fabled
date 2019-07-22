import UIKit.UIViewController

extension UIView {
    /// Convenience method for adding multiple subviews.
    /// - parameter views: A variadic list of views to add as subviews to this view.
    func addSubviews(_ views: UIView...) {
        views.forEach(addSubview)
    }
}

extension UILayoutPriority {
    /// Returns a priority of the maximum value (`1000`).
    static var max: UILayoutPriority {
        return .init(1000)
    }
}

extension Bundle {
    var releaseVersionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    var buildVersionNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? ""
    }
}

extension UIDevice {
    /// Devices with a home button have no bottom layout margin, which makes layout inconsistent across devices.
    /// This can be used to normalize.
    var hasHomeButton: Bool {
        if #available(iOS 11.0, *), UIApplication.shared.windows[0].safeAreaInsets.bottom > 0.0 {
            return false
        }
        return true
    }
    /// Devices running iOS 10.3 or older have no top layout margin, which makes layout inconsistent across devices.
    /// This can be used to normalize.
    var isRunningIOS10: Bool {
        if #available(iOS 11.0, *) {
            return false
        }
        return true
    }
}

func fatalError(_ error: Swift.Error) -> Never {
    return fatalError(error.localizedDescription)
}
