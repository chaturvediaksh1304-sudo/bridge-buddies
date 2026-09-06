import SwiftUI

/// Chat List — main tab.
///
/// Brand header (greeting + the user's own presence picker), a search pill that
/// straddles the header's bottom curve, then conversations sitting directly on
/// the screen gradient. No card behind the rows, so `Spacing.screenH` is the only
/// thing aligning the list — every row leads from it.
struct ChatListView: View {
    let userName = "Zainab"

    @State private var myStatus: PresenceStatus = .available
    @State private var searchText = ""
    @State private var openedConversation: String?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var visible: [Conversation] {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        return query.isEmpty ? Self.seed
            : Self.seed.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                LinearGradient.canvas.ignoresSafeArea()

                VStack(spacing: 0) {
                    header

                    SearchActionBar(text: $searchText, placeholder: "Tap to search")
                        .padding(.horizontal, Spacing.screenH)
                        .padding(.top, Spacing.stack)

                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(visible) { chat in
                                ChatListRow(
                                    name: chat.name,
                                    preview: chat.preview,
                                    timestamp: chat.timestamp,
                                    status: chat.status,
                                    isUnread: chat.isUnread,
                                    avatarTint: chat.tint,
                                    action: { openedConversation = chat.name }
                                )
                            }
                        }
                        .padding(.horizontal, Spacing.screenH)
                        .padding(.top, Spacing.stack)
                        .padding(.bottom, Spacing.tabBarClearance)
                        .animation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 1.0),
                                   value: visible.count)
                    }
                    .scrollDismissesKeyboard(.interactively)
                }
                .ignoresSafeArea(edges: .top)
            }
            .navigationBarHidden(true)
            .navigationDestination(item: $openedConversation) { name in
                ChatThreadView(conversationName: name)
            }
        }
    }

    private var header: some View {
        VStack(spacing: Spacing.stack) {
            Text("Hi \(userName)!")
                .font(.displaySM)
                .foregroundColor(.textPrimary)

            StatusSelector(selection: $myStatus)
                .padding(.horizontal, Spacing.screenH)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 64)
    }
}

// MARK: - Seed data

private struct Conversation: Identifiable {
    let id = UUID()
    let name: String
    let preview: ChatListRow.Preview
    let timestamp: String
    let status: PresenceStatus
    var isUnread: Bool = false
    let tint: Color
}

private extension ChatListView {
    static let seed: [Conversation] = [
        .init(name: "Aksh Chaturvedi", preview: .incoming("How are you doing?"),
              timestamp: "2m", status: .available, isUnread: true, tint: .heraeOlive),
        .init(name: "Aiden", preview: .sent(prefix: "Sent:", body: "What are your...."),
              timestamp: "11m", status: .away, isUnread: true, tint: .heraeCream),
        .init(name: "Christian Dunn", preview: .reaction("Reacted to your message"),
              timestamp: "56m", status: .busy, tint: .statusNone),
        .init(name: "Fatima Malik", preview: .sent(prefix: "Sent:", body: "So sorry about t..."),
              timestamp: "2h", status: .available, tint: .heraeSage),
        .init(name: "Marayla", preview: .sent(prefix: "You:", body: "Thank you so much?"),
              timestamp: "14h", status: .none, tint: .surfaceSolid),
        .init(name: "M. Beecham", preview: .reaction("You reacted"),
              timestamp: "1d", status: .away, tint: .heraeCream),
        .init(name: "Maaz", preview: .sent(prefix: "You:", body: "Most welcome!"),
              timestamp: "1d", status: .none, isUnread: true, tint: .heraeSage)
    ]
}

#Preview {
    ChatListView()
}
