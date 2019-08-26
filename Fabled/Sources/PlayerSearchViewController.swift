import UIKit
import Model
import PromiseKit

final class PlayerSearchViewController: DeclarativeViewController, RootPresentationViewControllerDelegate {
  private let playerSearchPlatform = State(initialValue: Platform.all)
  private let playerSearchText = State(initialValue: "")
  private let player = State<Player?>(initialValue: .none)

  private weak var profileRequest: Promise<Profile>?

  override var layout: Layout {
    return
      Layout(in: view,
        StackView(.vertical, [
          Spacer(.flexible),

          View(UIImageView(image: #imageLiteral(resourceName: "fabled-alpha")))
            .size(DisplayScale.x375.scale(250)),

          //MARK: Image and Title Header

          StackView(.vertical, [
            Text("Fabled")
              .font(Style.Font.NeueHaasGrotesk65Medium)
              .fontSize(40)
              .color(.white),

            Spacer(4),

            Text("Destiny 2 Glory Tracker")
              .font(Style.Font.text)
              .color(.white),
          ])
          .alignment(.center)
          .offset(.vertical, -26), //Inset title text into image view

          Spacer(32),

          //MARK: Interactive Fields

          StackView(.vertical, [
            SegmentedControl(playerSearchPlatform.binding)
              .font(Style.Font.text)
              .titleColor(.white)
              .titleColor(.black, while: .selected, .highlighted)
              .tintColor(.white)
              .backgroundColor(.clear),

            Spacer(32 + 8), //+8 accounts for "View Glory" button's label inset

            StackView(.horizontal, [
              Spacer(19.5), //Width of righthand activity indicator in text field

              TextField(playerSearchText.binding)
                .updatesRateLimited(to: 1.0)
                .textAlignment(.center)
                .autocorrectionType(.no)
                .autocapitalizationType(.none)
                .keyboardType(.twitter) //For BattleTag hash
                .font(Style.Font.text)
                .fontSize(16)
                .placeholder("Select a platform to narrow your search")
                .transforming(when: playerSearchPlatform.binding, updatePlayerSearchFieldPlaceholder)
                .placeholderColor(.lightGray)
                .textColor(.white)
                .cursorColor(.white)
                .rightView(playerSearchActivityIndicator, mode: .always)
                .endEditingOnReturn()
            ]),

            Spacer(32),

            StackView(.horizontal, [
              Spacer(8 + 20), //Intrisic size of righthand activity indicator + spacing

              Button("View Glory Profile")
                .observe(with: onViewPressed)
                .isEnabled(when: player.binding) { $0 != nil }
                .font(Style.Font.NeueHaasGrotesk65Medium)
                .fontSize(17)
                .titleColor(.white)
                .titleColor(.darkGray, while: .disabled),

              Spacer(8),

              View(profileFetchActivityIndicator)
            ])
            .alignment(.center)
          ])
          .alignment(.center)
          .adjustsForKeyboard(obscureOtherContent: true),

          Spacer(DisplayScale.x375.scale(100)), //Counterbalance header image to keep fields more centered
          Spacer(.flexible)
        ])
        .alignment(.center)
      )
      .pinnedToEdges()
  }

  private let playerSearchActivityIndicator = UIActivityIndicatorView(style: .white)
  private let profileFetchActivityIndicator = UIActivityIndicatorView(style: .white)

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = Style.Color.background

    //Kickoff search when search text updates
    playerSearchText.binding.observe { [weak self] playerName in
      guard let self = self, !playerName.isEmpty else { return }

      self.playerSearchActivityIndicator.startAnimating()

      Bungie.searchForPlayer(with: playerName, on: self.playerSearchPlatform.snapshot.forBungie)
        .done { self.player.binding.emit($0.first) }
        .ensure { self.playerSearchActivityIndicator.stopAnimating() }
        .cauterize()
    }

    //Kickoff search when platform selection updates while a player name is entered
    playerSearchPlatform.binding.observe { [weak self] _ in
      self?.playerSearchText.broadcast()
    }
  }

  /// Text field transform when selected platform updates.
  private func updatePlayerSearchFieldPlaceholder(_ platform: Platform, _ field: TextField) {
    switch platform {
    case .xbox:
      field.placeholder = "Gamertag"
      field.keyboardType = .default
    case .psn:
      field.placeholder = "PSN ID"
      field.keyboardType = .default
    case .blizzard:
      field.placeholder = "BattleTag#1234"
      field.keyboardType = .twitter
    case .all:
      field.placeholder = "Select a platform to narrow your search"
      field.keyboardType = .twitter
    }

    field.reloadInputViews()
  }

  private func onViewPressed(_ sender: UIButton) {
    guard profileRequest == nil || profileRequest?.isPending == false else { return }

    guard let player = self.player.snapshot else { return }

    UserDefaults.fabled().saveNewPlayerSearchResult(player)

    profileFetchActivityIndicator.startAnimating()

    profileRequest = Bungie.getProfile(for: player)

    profileRequest!
      .done { self.presentationShouldTransition(to: GloryProfileViewController(profile: $0)) }
      .ensure { self.profileFetchActivityIndicator.stopAnimating() }
      .catch { self.presentationShouldDisplayAlert(for: $0) }

    view.endEditing(true)
  }

  #if DEBUG
  deinit {
    // Ensuring I immediately catch retain cycles.
    print("\(type(of: self)) deinit")
  }
  #endif

}

// Can't use Bungie.Platform because .blizzard == 4 which screws up our SegmentedControl
// Strictly, should provide a more robust interface for SegmentedControl so this isn't necessary
private enum Platform: Int, CaseIterable, CustomStringConvertible {
  case xbox, psn, blizzard
  case all = -1

  var forBungie: Bungie.Platform {
    switch self {
    case .xbox: return .xbox
    case .psn: return .psn
    case .blizzard: return .blizzard
    default: return .all
    }
  }

  var description: String {
    switch self {
    case .xbox: return "XBOX"
    case .psn: return "PSN"
    case .blizzard: return "PC"
    default: return ""
    }
  }

  static var allCases: [Platform] {
    return [.xbox, .psn, .blizzard]
  }
}
