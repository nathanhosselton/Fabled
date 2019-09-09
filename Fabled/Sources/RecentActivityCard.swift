import UIKit

final class RecentActivityCard: CardView {
  private let currentWinStreakValue: Binding<String>
  private let matchesThisWeekText: Binding<String>
  private let winsThisWeekText: Binding<String>
  
  override var body: StackView {
    return
      StackView(.horizontal, [
        Text(currentWinStreakValue)
          .styleProvider(primaryValueTextStyling),

        Spacer(CardView.Spacing.title),

        StackView(.vertical, [
          Text("Current win streak")
            .styleProvider(headerTextStyling),

          Spacer(CardView.Spacing.heading),

          Text(matchesThisWeekText)
            .styleProvider(bodyTextStyling),

          Spacer(CardView.Spacing.body),

          Text(winsThisWeekText)
            .styleProvider(bodyTextStyling)
        ])
        .alignment(.leading)
      ])
      .alignment(.center)
  }

  init(winStreak: Binding<UInt>, matchesPlayed: Binding<Int>, matchesWon: Binding<Int>) {
    currentWinStreakValue = winStreak.map(String.init)
    matchesThisWeekText = matchesPlayed.map { String($0) + ($0 == 1 ? " match" : " matches") + " this week" }
    winsThisWeekText = matchesWon.map { String($0) + ($0 == 1 ? " win" : " wins") + " this week" }
    super.init()
  }

  @available(*, unavailable)
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
