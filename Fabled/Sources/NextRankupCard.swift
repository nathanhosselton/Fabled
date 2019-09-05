import UIKit

final class NextRankupCard: CardView {
  private var gloryToNextRankText: Binding<String>
  private var winsToNextRankText: Binding<String>
  private var moreWinsText: Binding<String>

  override var body: StackView {
    return
      StackView(.vertical, [
        Spacer(6),

        StackView(.horizontal, [
          Spacer(20),

          Text(gloryToNextRankText)
            .font(Style.Font.thicc)
            .fontSize(CardView.Font.titleSize)
            .adjustsFontSizeRelativeToDisplay(.x375)
            .color(Style.Color.text)
            .contentHuggingPriority(.max),

          Spacer(10),

          Text("Glory to next\nrank-up")
            .numberOfLines(2)
            .font(Style.Font.heading)
            .fontSize(CardView.Font.headingSize)
            .adjustsFontSizeRelativeToDisplay(.x375)
            .color(Style.Color.text)
            .contentCompressionResistance(.max)
            .contentHuggingPriority(.max, .vertical),

          Spacer(20)
        ])
        .adjustsSpacingRelativeToDisplay(.x375)
        .alignment(.center, preservingSubviews: true)
        .contentHuggingPriority(.max),

        Spacer(4),

        Text("That's  ")
          .fontSize(CardView.Font.bodySize)
          .color(Style.Color.text)
        +
        Text(winsToNextRankText)
          .font(Style.Font.heading)
          .fontSize(CardView.Font.bodySize)
          .color(Style.Color.text)
        +
        Text(moreWinsText)
          .fontSize(CardView.Font.bodySize)
          .color(Style.Color.text),

        Spacer(8)
      ])
      .adjustsSpacingRelativeToDisplay(.x375)
      .alignment(.center)
      .contentHuggingPriority(.max, .horizontal)
  }

  init(gloryRemaining: Binding<Int>, winsRemaining: Binding<UInt>) {
    gloryToNextRankText = gloryRemaining.map { String($0) }
    winsToNextRankText = winsRemaining.map { String($0) }
    moreWinsText = winsRemaining.map { "  more win" + ($0 == 1 ? "" : "s" )}
    super.init()
  }

  @available(*, unavailable)
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
