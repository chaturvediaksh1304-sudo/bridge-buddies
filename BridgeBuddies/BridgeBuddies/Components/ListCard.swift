import SwiftUI

/// Large white rounded card housing a scrollable list. §2.6.
struct ListCard<Content: View>: View {
    /// `true` sizes the card to its content instead of scrolling inside it —
    /// for cards whose contents are fixed (the two on Profile), where the
    /// ScrollView's greedy vertical sizing is wrong.
    var hugsContent: Bool = false
    @ViewBuilder let content: Content

    var body: some View {
        Group {
            if hugsContent {
                stack
            } else {
                ScrollView { stack }
            }
        }
        .background(Color.surfaceCardPure)
        .clipShape(RoundedRectangle(cornerRadius: Radius.card))
        .cardShadow()
    }

    private var stack: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .padding(20)
    }
}
