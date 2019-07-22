import UIKit
import Model

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Bungie.key = FabledAppKey
        Bungie.appId = FabledAppId
        Bungie.appVersion = Bundle.main.releaseVersionNumber

        DisplayScale.maxScaling = .x375

        window = UIWindow(rootViewController: RootPresentationViewController())
        window!.makeKeyAndVisible()

        return true
    }

}

extension UserDefaults {
    private static var fabledSuite: String {
        return "dev.NathanHosselton.iOS.Fabled.UserDefaults"
    }

    private static var LastPlayerSearchResult: String {
        return #function
    }

    static func fabled() -> UserDefaults {
        return UserDefaults(suiteName: fabledSuite)!
    }

    var lastPlayerSearchResult: Player? {
        guard let data = value(forKey: UserDefaults.LastPlayerSearchResult) as? Data else { return nil }
        return try? JSONDecoder().decode(Player.self, from: data)
    }

    func saveNewPlayerSearchResult(_ player: Player) {
        guard let data = try? JSONEncoder().encode(player) else { return }
        setValue(data, forKey: UserDefaults.LastPlayerSearchResult)
    }
}

extension UIWindow {
    /// Mimics the hidden `AppDelegate.window` constructor that is used when storyboards are present.
    convenience init(rootViewController: UIViewController) {
        self.init(frame: UIScreen.main.bounds)
        self.backgroundColor = .black //…except we go black
        self.rootViewController = rootViewController
    }
}
