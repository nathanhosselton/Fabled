import UIKit

final class WeeklyBonusCard: CardView {
  private weak var metWeeklyBonus: Binding<Bool>!
  private weak var willRankUp: Binding<Bool>!

  private let matchesRemainingValue: Binding<String>
  private let gloryAtNextResetValue: Binding<String>
  private let optimisticGloryAtNextResetValue: Binding<String>

  private let matchesRemainingIndicator: Binding<String>
  private let matchesRemainingText: Binding<String>
  private let bonusOrDecayText: Binding<String>

  override var body: StackView {
    return
      StackView(.horizontal, [
        StackView(.horizontal, [
          Spacer(.flexible),

          Text(matchesRemainingValue)
            .font(Style.Font.thicc)
            .fontSize(CardView.Font.titleSize)
            .transforming(when: metWeeklyBonus) { $1.textColor = $0 ? Style.Color.text : Style.Color.imperativeText },

          Text(matchesRemainingIndicator)
            .font(Style.Font.thicc)
            .fontSize(44)
            .adjustsFontSizeRelativeToDisplay(.x375)
            .color(Style.Color.imperativeText)
            .offset(.vertical, -2),

          Spacer(.flexible)
        ])
        .alignment(.center)
        .width(CardView.Spacing.minimumTitleWidth),

        Spacer(CardView.Spacing.title),

        StackView(.vertical, [
          Text(matchesRemainingText)
            .styleProvider(headerTextStyling),

          //FIXME: On x320 devices the above label's font is reduced but the below's is not
          //Need e.g. `Binding.join(…)` so these can be a single Label instead of two.
          Text(bonusOrDecayText)
            .styleProvider(headerTextStyling),

          Spacer(CardView.Spacing.heading),

          If(metWeeklyBonus).then(
            Text("You'll have ", gloryAtNextResetValue, " Glory at next reset")
              .numberOfLines(2)
              .styleProvider(bodyTextStyling)
          ).else(
            Text("Win your next match for at least ", optimisticGloryAtNextResetValue, " Glory at next reset")
              .numberOfLines(2)
              .styleProvider(bodyTextStyling)
          ),

          If(willRankUp).then(
            Spacer(CardView.Spacing.heading),

            Text("Ranking up".uppercased())
              .font(Style.Font.heading)
              .fontSize(CardView.Font.bodySize)
              .color(Style.Color.imperativeText)
          )
        ])
        .alignment(.leading)
      ])
      .alignment(.center)
  }

  init(bonusMet: Binding<Bool>, rankingUp: Binding<Bool>, matchesRemaining: Binding<Int>, realGlory: Binding<Int>, optimisticGlory: Binding<Int>, currentRankDecays: Binding<Bool>) {
    metWeeklyBonus = bonusMet
    willRankUp = rankingUp

    matchesRemainingValue = matchesRemaining.map(String.init)
    gloryAtNextResetValue = realGlory.map(String.init)
    optimisticGloryAtNextResetValue = optimisticGlory.map(String.init)

    matchesRemainingIndicator = bonusMet.map { $0 ? "" : "▴" }
    matchesRemainingText = matchesRemaining.map { $0 == 1 ? "Match remaining" : "Matches remaining" }
    bonusOrDecayText = currentRankDecays.map { $0 ? "to avoid decay" : "to weekly bonus" }

    super.init()
  }

  @available(*, unavailable)
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
