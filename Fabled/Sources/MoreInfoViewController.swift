import UIKit
import Model

final class MoreInfoViewController: DeclarativeViewController {
  private var threshold: Int { return GloryRank.WeeklyMatchCompletionThreshold }

  private let textSize: CGFloat = 14
  private let sectionSpacing: CGFloat = 14

  override var layout: Layout {
    return
      Layout(in: view,
        StackView(.vertical, [
          Spacer(sectionSpacing),

          //MARK: FAQ

          Scrollable(contentView:
            StackView(.vertical, [
              Text("FAQ")
                .font(Style.Font.title)
                .alignment(.center)
                .fontSize(24)
                .color(.white),

              Spacer(sectionSpacing),

              //MARK: Bonus Glory

              Text("Bonus Glory?")
                .styleProvider(faqHeaderStyling),

              Spacer(4),

              Text("""
                Playing \(threshold) matches within a weekly reset period awards \
                bonus Glory at the next weekly reset until Mythic rank.
                """)
                .styleProvider(faqBodyStyling),

              Spacer(8),

              //MARK: Predicting Glory

              Text("You're predicting my Glory?")
                .styleProvider(faqHeaderStyling),

              Spacer(4),

              Text("""
                When you haven't yet met the weekly bonus, we add it to \
                the Glory earned if your next match is a win to give you a \
                picture of what your Glory could be. If you need additional \
                matches for the bonus from there we assume those are losses.
                """)
                .styleProvider(faqBodyStyling),

              Spacer(4),

              Text("We do this because this is always a net-gain week-over-week until you reach Fabled.")
                .styleProvider(faqBodyStyling),

              //MARK: Divider

              Spacer(sectionSpacing),

              Text("— —")
                .alignment(.center)
                .font(Style.Font.body)
                .fontSize(22)
                .color(.white),

              Spacer(sectionSpacing),

              //MARK: Shadowkeep Disclaimer

              StackView(.horizontal, [
                Text("October 1")
                  .styleProvider(categoryColumnStyling)
                  .color(.red),

                Spacer(10),

                StackView(.vertical, [
                  Text("""
                    Bungie announced that Glory points and ranks will be changing \
                    beginning with Shadowkeep. It is very likely that this app will \
                    no longer provide correct information at that time.
                    """)
                    .styleProvider(bodyColumnStyling),

                  Spacer(4),

                  Text("""
                    When the specifics of the new Glory system are revealed, this \
                    app will be updated to reflect (if possible).
                    """)
                    .styleProvider(bodyColumnStyling)
                ])
              ])
              .alignment(.firstBaseline, preservingSubviews: true),

              //MARK: Feedback

              Spacer(sectionSpacing),

              StackView(.horizontal, [
                Text("Feedback")
                  .styleProvider(categoryColumnStyling),

                Spacer(10),

                StackView(.vertical, [
                  Button("Fabled on GitHub")
                    .observe(with: onFeedbackPressed)
                    .contentHuggingPriority(.max),

                  Text("""
                    Feel free to submit any bugs, requests, or general feedback \
                    by opening a new Issue.
                    """)
                    .styleProvider(bodyColumnStyling)
                ])
                .alignment(.leading)
              ])
              .alignment(.firstBaseline, preservingSubviews: true),

              //MARK: Clan

              Spacer(sectionSpacing),

              StackView(.horizontal, [
                Text("Clan")
                  .styleProvider(categoryColumnStyling),

                Spacer(10),

                StackView(.vertical, [
                  Button("Meow Pew Pew on Bungie")
                    .observe(with: onClanPressed),

                  Text("We're always welcoming chill new members (PC).")
                    .styleProvider(bodyColumnStyling)
                ])
                .alignment(.leading)
              ])
              .alignment(.firstBaseline, preservingSubviews: true),

              //MARK: Discord

              Spacer(sectionSpacing),

              StackView(.horizontal, [
                Text("Discord")
                  .styleProvider(categoryColumnStyling),

                Spacer(10),

                StackView(.vertical, [
                  Button("Meow Pew Pew on Discord")
                    .observe(with: onDiscordPressed),

                  Text("We also play lots of other games.")
                    .styleProvider(bodyColumnStyling)
                ])
                .alignment(.leading)
              ])
              .alignment(.firstBaseline, preservingSubviews: true),

              //MARK: Raid Dad

              Spacer(sectionSpacing),

              StackView(.horizontal, [
                Text("Raid Dad")
                  .styleProvider(categoryColumnStyling),

                Spacer(10),

                StackView(.vertical, [
                  Button("Destiny Analysis Dashboard")
                    .observe(with: onRaidDadPressed),

                  Text("Become pinnacle father.")
                    .styleProvider(bodyColumnStyling)
                ])
                .alignment(.leading)
              ])
              .alignment(.firstBaseline, preservingSubviews: true),

              //MARK: Follow

              Spacer(sectionSpacing),

              StackView(.horizontal, [
                Text("Follow")
                  .styleProvider(categoryColumnStyling),

                Spacer(10),

                StackView(.vertical, [
                  Button("Me on Twitter")
                    .observe(with: onFollowPressed),

                  Text("It's your funeral.")
                    .styleProvider(bodyColumnStyling)
                ])
                .alignment(.leading)
              ])
              .alignment(.firstBaseline, preservingSubviews: true)
            ])
            .alignment(.fill, preservingSubviews: true)
          )
          .styleProvider(scrollViewStyling),

          //MARK: Dismiss

          StackView(.horizontal, [
            Spacer(.flexible),

            Button("   Done   ")
              .observe(with: onGoBackPressed)
              .font(Style.Font.title)
              .fontSize(16)
              .titleColor(.white)
              .backgroundColor(Style.Color.backdrop)
              .cornerRadius(8),
          ]),

          Spacer(sectionSpacing)
        ])
      )
      .pinned([.leading, .trailing, .bottom])
      .pinned([.top], padding: UIDevice.current.isRunningIOS10 ? 20 : 0)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor(white: 0.0, alpha: 0.866)

    //HACK: Add background to status bar since scroll view content not clipped to bounds
    let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
    statusBarView.backgroundColor = view.backgroundColor
    view.addSubview(statusBarView)
  }

  private func faqHeaderStyling(_ label: UILabel) {
    label.font = Style.Font.heading.withSize(16)
    label.textColor = .white
  }

  private func faqBodyStyling(_ label: UILabel) {
    label.numberOfLines = 0
    label.font = Style.Font.body.withSize(textSize)
    label.textColor = .white
  }

  private func categoryColumnStyling(_ label: UILabel) {
    label.font = Style.Font.heading.withSize(16)
    label.textColor = .white
    label.textAlignment = .right
    label.widthAnchor.constraint(equalToConstant: 76).isActive = true
  }

  private func bodyColumnStyling(_ label: UILabel) {
    label.numberOfLines = 0
    label.font = Style.Font.body.withSize(textSize)
    label.textColor = .white
  }

  private func scrollViewStyling(_ scroll: UIScrollView) {
    scroll.indicatorStyle = .white
    //FIXME: Hack to push scroll indicator outside of content
    scroll.scrollIndicatorInsets.right -= 12
    scroll.clipsToBounds = false
  }

  private func onFeedbackPressed() {
    UIApplication.shared.open(URL(string: "https://github.com/nathanhosselton/Fabled")!)
  }

  private func onClanPressed() {
    UIApplication.shared.open(URL(string: "https://www.bungie.net/en/ClanV2/Index?groupId=2771930")!)
  }

  private func onDiscordPressed() {
    UIApplication.shared.open(URL(string: "https://discord.gg/2HDUFcF")!)
  }

  private func onRaidDadPressed() {
    UIApplication.shared.open(URL(string: "https://raiddad.com")!)
  }

  private func onFollowPressed() {
    UIApplication.shared.open(URL(string: "https://twitter.com/witha3")!)
  }

  private func onGoBackPressed() {
    presentingViewController?.dismiss(animated: true)
  }

  override var modalPresentationStyle: UIModalPresentationStyle {
    get { return .overCurrentContext }
    set {}
  }

  override var modalTransitionStyle: UIModalTransitionStyle {
    get { return .crossDissolve }
    set {}
  }

  #if DEBUG
  deinit {
    // Ensuring I immediately catch retain cycles.
    print("\(type(of: self)) deinit")
  }
  #endif
}
