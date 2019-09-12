import UIKit
import Model
import PromiseKit

class GloryProfileViewController: DeclarativeViewController, RootPresentationViewControllerDelegate {
  private let playerProfile: State<Profile>

  private var refreshRequest: Promise<Profile>?

  //Header
  private lazy var playerName = playerProfile.binding.map { $0.player.displayName }
  private lazy var playerRank = playerProfile.binding.map { $0.rankText }
  private lazy var currentGlory = playerProfile.binding.map { String($0.glory.currentProgress) }

  //NextRankUpCard
  private lazy var nextRank = playerProfile.binding.map { $0.gloryToNextRank }
  private lazy var winsToNextRank = playerProfile.binding.map { $0.winsToNextRank }

  //RecentActivityCard
  private lazy var currentWinStreak = playerProfile.binding.map { $0.currentWinStreak }
  private lazy var matchesPlayedThisWeek = playerProfile.binding.map { $0.matchesPlayedThisWeek }
  private lazy var matchesWonThisWeek = playerProfile.binding.map { $0.matchesWonThisWeek }

  //WeeklyBonusCard
  private lazy var metWeeklyBonus = playerProfile.binding.map { $0.hasMetThresholdRequirementThisWeek }
  private lazy var willRankUpAtReset = playerProfile.binding.map { $0.willRankUpAtReset }
  private lazy var matchesRemainingForWeeklyBonus = playerProfile.binding.map { $0.matchesRemainingToWeeklyThreshold }
  private lazy var gloryAtNextWeeklyReset = playerProfile.binding.map { $0.gloryAtNextWeeklyReset }
  private lazy var optimisticGloryAtNextWeeklyReset = playerProfile.binding.map { $0.optimisticGloryAtNextWeeklyReset }
  private lazy var currentRankDecays = playerProfile.binding.map { $0.canIncurGloryDecay }

  //Footer
  private lazy var winsToFabled = playerProfile.binding.map { String($0.winsToFabled) }
  private lazy var winsToFabledIsZero = playerProfile.binding.map { $0.winsToFabled == 0 }
  private lazy var moreWinsText = playerProfile.binding.map { "  more win" + ($0.winsToFabled != 1 ? "s" : "") }

  override var layout: Layout {
    return
      Layout(in: view,
         StackView(.vertical, [
          Spacer(.flexible),

          //MARK: Player Name, Glory & Rank

          Text(playerName)
            .font(Style.Font.title)
            .fontSize(36)
            .adjustsFontSizeRelativeToDisplay(.x375)
            .color(Style.Color.text),

          Spacer(DisplayScale.x375.scale(8)),

          Text(currentGlory)
            .fontSize(22)
            .adjustsFontSizeRelativeToDisplay(.x375)
            .color(Style.Color.text)
          +
          Text(" Glory   —   ")
            .fontSize(22)
            .adjustsFontSizeRelativeToDisplay(.x375)
            .color(Style.Color.text)
          +
          Text(playerRank)
            .fontSize(22)
            .adjustsFontSizeRelativeToDisplay(.x320)
            .color(Style.Color.imperativeText),

          Spacer(DisplayScale.x320.scale(12)),

          //MARK: Cards

          NextRankupCard(gloryRemaining: nextRank, winsRemaining: winsToNextRank),

          Spacer(DisplayScale.x375.scale(18)),

          RecentActivityCard(winStreak: currentWinStreak, matchesPlayed: matchesPlayedThisWeek, matchesWon: matchesWonThisWeek),

          Spacer(DisplayScale.x375.scale(18)),

          WeeklyBonusCard(bonusMet: metWeeklyBonus, rankingUp: willRankUpAtReset, matchesRemaining: matchesRemainingForWeeklyBonus, realGlory: gloryAtNextWeeklyReset, optimisticGlory: optimisticGloryAtNextWeeklyReset, currentRankDecays: currentRankDecays),

          //MARK: Wins to Fabled

          Spacer(DisplayScale.x320.scale(12)),

          Text(winsToFabled)
            .font(Style.Font.heading)
            .adjustsFontSizeRelativeToDisplay(.x320)
            .transforming(when: winsToFabledIsZero) { $0.textColor = Style.Color.text }
            .transforming(when: winsToFabledIsZero, is: false) { $0.textColor = Style.Color.imperativeText }
          +
          Text(moreWinsText)
            .font(Style.Font.heading)
            .adjustsFontSizeRelativeToDisplay(.x320)
            .color(Style.Color.text)
          +
          Text(" to reach Fabled")
            .adjustsFontSizeRelativeToDisplay(.x320)
            .color(Style.Color.text),

          //MARK: Change Account, Refresh, & More Info

          Spacer(.flexible),

          StackView(.horizontal, [
            Button(#imageLiteral(resourceName: "escape_regular_m"))
              .observe(with: onChangePlayerPressed)
              .size(22)
              .tintColor(Style.Color.deemphasized),

            Spacer(50),

            Button(#imageLiteral(resourceName: "refresh_regular_m"))
              .observe(with: onRefreshPressed)
              .size(22)
              .tintColor(Style.Color.interactive),

            Spacer(50),

            Button(#imageLiteral(resourceName: "question_regular_m"))
              .observe(with: onMoreInfoPressed)
              .size(23)
              .tintColor(Style.Color.deemphasized),
          ])
          .adjustsSpacingRelativeToDisplay(.x320)
          .alignment(.center)
        ])
        .alignment(.center)
      )
      .pinned([.leading, .trailing])
      .pinned([.top], padding: UIDevice.current.isRunningIOS10 ? 20 : 0)
      .pinned([.bottom], padding: UIDevice.current.hasHomeButton ? 8 : 0)
  }

  init(profile: Profile) {
    playerProfile = State(initialValue: profile)
    super.init(nibName: nil, bundle: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = Style.Color.background
    playerProfile.broadcast()
  }

  private func onChangePlayerPressed() {
    presentationShouldTransition(to: PlayerSearchViewController())
  }

  private func onRefreshPressed(_ sender: UIButton) {
    guard refreshRequest == nil || refreshRequest?.isPending == false else { return }

    //Set activity indicator into button
    let refreshAnimator = UIActivityIndicatorView(style: .white)
    refreshAnimator.translatesAutoresizingMaskIntoConstraints = false
    refreshAnimator.backgroundColor = .black

    sender.superview!.addSubview(refreshAnimator)

    NSLayoutConstraint.activate([
      refreshAnimator.widthAnchor.constraint(equalTo: sender.superview!.widthAnchor),
      refreshAnimator.heightAnchor.constraint(equalTo: sender.superview!.heightAnchor),
      refreshAnimator.centerXAnchor.constraint(equalTo: sender.superview!.centerXAnchor),
      refreshAnimator.centerYAnchor.constraint(equalTo: sender.superview!.centerYAnchor)
    ])

    refreshAnimator.startAnimating()

    refreshRequest = Bungie.getProfile(for: playerProfile.snapshot.player)

    refreshRequest!
      .done { self.playerProfile.binding.emit($0) }
      .ensure { refreshAnimator.removeFromSuperview() }
      .catch { self.presentationShouldDisplayAlert(for: $0) }
  }

  private func onMoreInfoPressed() {
    present(MoreInfoViewController(), animated: true)
  }

  #if DEBUG
  deinit {
    // Ensuring I immediately catch retain cycles.
    print("\(type(of: self)) deinit")
  }
  #endif

  //MARK: Unavailable

  @available(*, unavailable)
  required init(coder: NSCoder = .empty) {
    fatalError("\(#file + #function) is not available.")
  }

}
