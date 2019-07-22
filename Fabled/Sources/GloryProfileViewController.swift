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
  private lazy var metWeeklyBonus = playerProfile.binding.map { $0.hasMetBonusRequirementThisWeek }
  private lazy var willRankUpAtReset = playerProfile.binding.map { $0.willRankUpAtReset }
  private lazy var matchesRemainingForWeeklyBonus = playerProfile.binding.map { $0.matchesRemainingForWeeklyBonus }
  private lazy var gloryAtNextWeeklyReset = playerProfile.binding.map { $0.gloryAtNextWeeklyReset }
  private lazy var optimisticGloryAtNextWeeklyReset = playerProfile.binding.map { $0.optimisticGloryAtNextWeeklyReset }

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
            .font(Style.Font.NeueHaasGrotesk65Medium)
            .fontSize(36)
            .adjustsFontSizeRelativeToDisplay(.x375)
            .color(.white),

          Spacer(DisplayScale.x375.scale(8)),

          Text(currentGlory)
            .fontSize(22)
            .adjustsFontSizeRelativeToDisplay(.x375)
            .color(.white)
          +
          Text(" Glory   —   ")
            .fontSize(22)
            .adjustsFontSizeRelativeToDisplay(.x375)
            .color(.white)
          +
          Text(playerRank)
            .fontSize(24)
            .adjustsFontSizeRelativeToDisplay(.x320)
            .color(.red),

          Spacer(DisplayScale.x320.scale(12)),

          //MARK: Cards

          NextRankupCard(gloryRemaining: nextRank, winsRemaining: winsToNextRank),

          Spacer(DisplayScale.x375.scale(18)),

          RecentActivityCard(winStreak: currentWinStreak, matchesPlayed: matchesPlayedThisWeek, matchesWon: matchesWonThisWeek),

          Spacer(DisplayScale.x375.scale(18)),

          WeeklyBonusCard(bonusMet: metWeeklyBonus, rankingUp: willRankUpAtReset, matchesRemaining: matchesRemainingForWeeklyBonus, realGlory: gloryAtNextWeeklyReset, optimisticGlory: optimisticGloryAtNextWeeklyReset),

          //MARK: Wins to Fabled

          Spacer(DisplayScale.x320.scale(12)),

          Text(winsToFabled)
            .font(Style.Font.NeueHaasGrotesk65Medium)
            .adjustsFontSizeRelativeToDisplay(.x320)
            .transforming(when: winsToFabledIsZero) { $0.textColor = .white }
            .transforming(when: winsToFabledIsZero, is: false) { $0.textColor = .red }
          +
          Text(moreWinsText)
            .font(Style.Font.NeueHaasGrotesk65Medium)
            .adjustsFontSizeRelativeToDisplay(.x320)
            .color(.white)
          +
          Text(" to reach Fabled")
            .adjustsFontSizeRelativeToDisplay(.x320)
            .color(.white),

          //MARK: Change Account, Refresh, & More Info

          Spacer(.flexible),

          StackView(.horizontal, [
            Button(#imageLiteral(resourceName: "logout_icon"))
              .observe(with: onChangePlayerPressed)
              .size(22)
              .tintColor(.lightGray),

            Spacer(48), //visual centering

            Button(#imageLiteral(resourceName: "refresh_icon"))
              .observe(with: onRefreshPressed)
              .size(22)
              .tintColor(.white),

            Spacer(50),

            Button("?")
              .observe(with: onMoreInfoPressed)
              .styleProvider(moreInfoButtonStyling)
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
    //FIXME: Build into `DeclarativeViewController`
    playerProfile.broadcast()
  }

  private func moreInfoButtonStyling(_ button: UIButton) {
    button.titleLabel?.font = UIFont(name: Style.Font.NeueHaasGrotesk65Medium, size: 14)
    button.titleEdgeInsets.top = 1
    button.setTitleColor(.lightGray, for: .normal)

    let size: CGFloat = 22
    button.widthAnchor.constraint(equalToConstant: size).isActive = true
    button.heightAnchor.constraint(equalToConstant: size).isActive = true

    button.layer.cornerRadius = size / 2
    button.layer.borderColor = UIColor.lightGray.cgColor
    button.layer.borderWidth = 1.666
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
