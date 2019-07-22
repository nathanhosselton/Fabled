import UIKit

final class WeeklyBonusCard: CardView {
  private weak var metWeeklyBonus: Binding<Bool>!
  private weak var willRankUp: Binding<Bool>!

  private let matchesRemainingForWeeklyBonus: Binding<String>
  private let gloryAtNextWeeklyReset: Binding<String>
  private let optimisticGloryAtNextWeeklyReset: Binding<String>

  private let rankingUpText: Binding<String>

  override var body: StackView {
    return
      StackView(.vertical, [
        Spacer(6),

        StackView(.horizontal, [
          Spacer(20),

          Text(matchesRemainingForWeeklyBonus)
            .font(Style.Font.NeueHaasGrotesk65Medium)
            .fontSize(60)
            .adjustsFontSizeRelativeToDisplay(.x375)
            .transforming(when: metWeeklyBonus) { $0.textColor = .white }
            .transforming(when: metWeeklyBonus, is: false) { $0.textColor = .red }
            .contentHuggingPriority(.max),

          Spacer(10),

          Text("Matches remaining\nto weekly bonus")
            .numberOfLines(2)
            .fontSize(20)
            .adjustsFontSizeRelativeToDisplay(.x375)
            .color(.white)
            .contentCompressionResistance(.max)
            .contentHuggingPriority(.max, .vertical),

          Spacer(20)
        ])
        .adjustsSpacingRelativeToDisplay(.x375)
        .alignment(.center, preservingSubviews: true)
        .contentHuggingPriority(.max),

        Spacer(6),

        StackView(.horizontal, [
          Spacer(20),

          StackView(.vertical, [
            //if metWeeklyBonus == false

            Text("You'll have ")
              .fontSize(17)
              .adjustsFontSizeRelativeToDisplay(.x375)
              .color(.white)
              .isHidden(while: metWeeklyBonus, is: false)
            +
            Text(gloryAtNextWeeklyReset)
              .font(Style.Font.NeueHaasGrotesk65Medium)
              .fontSize(20)
              .adjustsFontSizeRelativeToDisplay(.x375)
              .color(.white)
              .isHidden(while: metWeeklyBonus, is: false)
            +
            Text(" Glory at next reset")
              .fontSize(17)
              .adjustsFontSizeRelativeToDisplay(.x375)
              .color(.white)
              .isHidden(while: metWeeklyBonus, is: false),

            //else

            Text("Win your next match for at least ")
              .color(.white)
              .fontSize(17)
              .adjustsFontSizeRelativeToDisplay(.x375)
              .isHidden(while: metWeeklyBonus),

            Text(optimisticGloryAtNextWeeklyReset)
              .font(Style.Font.NeueHaasGrotesk65Medium)
              .fontSize(20)
              .adjustsFontSizeRelativeToDisplay(.x375)
              .color(.white)
              .isHidden(while: metWeeklyBonus)
            +
            Text("  Glory at next reset")
              .fontSize(17)
              .adjustsFontSizeRelativeToDisplay(.x375)
              .color(.white)
              .isHidden(while: metWeeklyBonus),

            Spacer(2),

            Text(rankingUpText)
              .fontSize(20)
              .adjustsFontSizeRelativeToDisplay(.x375)
              .color(.red)

            //endif
          ])
          .alignment(.center),

          Spacer(20)
        ])
        .adjustsSpacingRelativeToDisplay(.x375),

        Spacer(8)
      ])
      .adjustsSpacingRelativeToDisplay(.x375)
      .alignment(.center)
      .contentHuggingPriority(.max, .horizontal)
  }

  init(bonusMet: Binding<Bool>, rankingUp: Binding<Bool>, matchesRemaining: Binding<Int>, realGlory: Binding<Int>, optimisticGlory: Binding<Int>) {
    metWeeklyBonus = bonusMet
    willRankUp = rankingUp

    matchesRemainingForWeeklyBonus = matchesRemaining.map(String.init)
    gloryAtNextWeeklyReset = realGlory.map(String.init)
    optimisticGloryAtNextWeeklyReset = optimisticGlory.map(String.init)

    rankingUpText = willRankUp.map { $0 ? "Ranking up" : "" }

    super.init()
  }

  @available(*, unavailable)
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
