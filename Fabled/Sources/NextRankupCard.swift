import UIKit

final class NextRankupCard: CardView {
  private let gloryToNextRankValue: Binding<String>
  private let winsToGoText: Binding<String>

  override var body: StackView {
    return
      StackView(.horizontal, [
        Text(gloryToNextRankValue)
          .styleProvider(primaryValueTextStyling),

        Spacer(CardView.Spacing.title),

        StackView(.vertical, [
          Text("Glory to next rank up")
            .styleProvider(headerTextStyling),
          
            Spacer(CardView.Spacing.heading),

            Text(winsToGoText)
              .styleProvider(bodyTextStyling)
        ])
        .alignment(.leading)
      ])
      .alignment(.center)
  }

  init(gloryRemaining: Binding<Int>, winsRemaining: Binding<UInt>) {
    gloryToNextRankValue = gloryRemaining.map(String.init)
    winsToGoText = winsRemaining.map { String($0) + ($0 == 1 ? " win" : " wins") + " to go"}
    super.init()
  }

  @available(*, unavailable)
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
