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
              .font(Style.Font.title)
              .fontSize(40)
              .color(Style.Color.text)
              .adjustsFontSizeRelativeToDisplay(.x375),

            Spacer(4),

            Text("Destiny 2 Glory Tracker")
              .font(Style.Font.body)
              .color(Style.Color.text)
              .adjustsFontSizeRelativeToDisplay(.x375),
          ])
          .alignment(.center)
          .offset(.vertical, -26), //Inset title text into image view

          Spacer(32),

          //MARK: Interactive Fields

          StackView(.vertical, [
            SegmentedControl(playerSearchPlatform.binding)
              .font(Style.Font.heading)
              .fontSize(DisplayScale.x375.scale(18))
              .titleColor(Style.Color.text)
              .titleColor(.black, while: .selected, .highlighted)
              .tintColor(Style.Color.interactive)
              .backgroundColor(.clear),

            Spacer(32 + 8), //+8 accounts for "View Glory" button's label inset

            TextField(playerSearchText.binding)
              .updatesRateLimited(to: 1.0)
              .placeholder("Select a platform" + (UIScreen.main.displayScale > .x320 ? " to narrow search" : ""))
              .transforming(when: playerSearchPlatform.binding, updatePlayerSearchFieldPlaceholder)
              .rightView(playerSearchActivityIndicator, mode: .always)
              .leftView(View().size(19.5), mode: .always) //Compensates for rightView
              .endEditingOnReturn()
              .font(Style.Font.body)
              .fontSize(DisplayScale.x320.scale(16))
              .textAlignment(.center)
              .autocorrectionType(.no)
              .autocapitalizationType(.none)
              .keyboardType(.twitter) //For BattleTag hash
              .placeholderColor(Style.Color.deemphasized)
              .textColor(Style.Color.text)
              .cursorColor(Style.Color.interactive)
              .backgroundColor(Style.Color.backdrop)
              .cornerRadius(DisplayScale.x320.scale(8))
              .width(view.bounds.width - Style.Layout.largeSpacing * 2)
              .height(DisplayScale.x320.scale(30)),

            Spacer(32),

            StackView(.vertical, [
              Button("View Glory Profile")
                .observe(with: onViewPressed)
                .isEnabled(when: player.binding) { $0 != nil }
                .font(Style.Font.heading)
                .fontSize(DisplayScale.x375.scale(18))
                .titleColor(Style.Color.text)
                .titleColor(Style.Color.disabled, while: .disabled),

              Spacer(Style.Layout.smallSpacing),

              View(profileFetchActivityIndicator)
            ])
            .alignment(.center)
          ])
          .alignment(.center)
          .adjustsForKeyboard(obscureOtherContent: true),

          Spacer(UIScreen.main.displayScale == .x320 ? 30 : 100), //Pad bottom of screen to keep fields more centered
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
        .catch {
          guard let error = $0 as? Bungie.Error, error == .systemDisabledForMaintenance else { return }
          self.presentationShouldDisplayAlert(for: error)
        }
    }

    //Kickoff search when platform selection updates while a player name is entered
    playerSearchPlatform.binding.observe { [weak self] _ in
      self?.playerSearchText.broadcast()
    }
  }

  /// Text field transform when selected platform updates.
  private var updatePlayerSearchFieldPlaceholder: (Platform, TextField) -> Void = { platform, field in
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
      field.placeholder = "Select a platform"
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
