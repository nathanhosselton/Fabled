import UIKit

final class RecentActivityCard: CardView {
  private var currentWinStreak: Binding<String>
  private var matchesPlayedThisWeek: Binding<String>
  private var matchesWonThisWeek: Binding<String>
  
  override var body: StackView {
    return
      StackView(.vertical, [
        Spacer(6),

        StackView(.horizontal, [
          Text("Current win\nstreak")
            .numberOfLines(2)
            .font(Style.Font.heading)
            .fontSize(CardView.Font.headingSize)
            .adjustsFontSizeRelativeToDisplay(.x375)
            .alignment(.right)
            .color(.white)
            .contentCompressionResistance(.max)
            .contentHuggingPriority(.max, .vertical),

          Spacer(10),

          Text(currentWinStreak)
            .font(Style.Font.thicc)
            .fontSize(CardView.Font.titleSize)
            .adjustsFontSizeRelativeToDisplay(.x375)
            .color(.white)
            .contentHuggingPriority(.max)
        ])
        .adjustsSpacingRelativeToDisplay(.x375)
        .alignment(.center, preservingSubviews: true)
        .contentHuggingPriority(.max),

        Spacer(6),

        StackView(.horizontal, [
          Spacer(20),

            .color(.white)
          Text("You've played ")
            .fontSize(CardView.Font.bodySize)
          +
          Text(matchesPlayedThisWeek)
            .color(.white)
            .font(Style.Font.heading)
            .fontSize(CardView.Font.bodySize)
          +
          .color(.white),
          Text(" matches this week")
          .fontSize(CardView.Font.bodySize)

          Spacer(20)
        ])
        .adjustsSpacingRelativeToDisplay(.x375),

        Spacer(2),

          .color(.white)
        Text("Winning ")
          .fontSize(CardView.Font.bodySize)
        +
        Text(matchesWonThisWeek)
          .color(.white),
          .font(Style.Font.heading)
          .fontSize(CardView.Font.bodySize)

        Spacer(8)
      ])
      .adjustsSpacingRelativeToDisplay(.x375)
      .alignment(.center)
      .contentHuggingPriority(.max, .horizontal)
  }

  init(winStreak: Binding<UInt>, matchesPlayed: Binding<Int>, matchesWon: Binding<Int>) {
    currentWinStreak = winStreak.map { String($0) }
    matchesPlayedThisWeek = matchesPlayed.map { String($0) }
    matchesWonThisWeek = matchesWon.map { String($0) }
    super.init()
  }

  @available(*, unavailable)
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
