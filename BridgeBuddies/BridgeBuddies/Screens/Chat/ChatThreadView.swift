import SwiftUI

// TODO: Chat Thread has no wireframe and no spec — nothing in `Initial/` covers it
// and UI_SPEC.md was never shipped. Deliberately left unbuilt rather than invented:
// message bubble shape, compose bar, reaction affordance, header contents and
// pagination behaviour are all undecided, and guessing them here would create a
// pattern the rest of the app would then be pressured to match.
//
// Blocked on: a wireframe or written spec.
struct ChatThreadView: View {
    let conversationName: String

    var body: some View {
        ZStack {
            LinearGradient.canvas.ignoresSafeArea()

            Text(conversationName)
                .font(.displaySM)
                .foregroundColor(.textPrimary)
        }
    }
}

#Preview {
    ChatThreadView(conversationName: "Aiden")
}
