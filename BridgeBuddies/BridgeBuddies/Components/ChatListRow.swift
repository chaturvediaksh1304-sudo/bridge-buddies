import SwiftUI

/// One conversation in the Chat List.
///
/// Sits directly on the screen gradient with no card behind it, so everything is
/// on-dark. The avatar's small orb doubles as the presence indicator, which is
/// why there's no separate `StatusDot` here — the wireframe uses the second orb
/// for exactly that job.
///
/// The row and the overflow control are siblings, not nested buttons, so each
/// gets its own clean hit target and press feedback.
struct ChatListRow: View {
    /// How the preview line reads. A reaction renders italic and unprefixed,
    /// matching the wireframe's treatment of non-message events.
    enum Preview {
        case incoming(String)
        case sent(prefix: String, body: String)
        case reaction(String)
    }

    let name: String
    let preview: Preview
    let timestamp: String
    var status: PresenceStatus = .none
    var isUnread: Bool = false
    var avatarTint: Color = .heraeOlive
    let action: () -> Void
    var onMenu: () -> Void = {}

    var body: some View {
        HStack(spacing: 12) {
            Button(action: action) {
                HStack(spacing: 14) {
                    DualOrbAvatar(size: 56, bigColor: avatarTint, smallColor: status.color)

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 8) {
                            Text(name)
                                .font(.system(size: 21, weight: .bold))
                                .foregroundColor(.textPrimary)
                                .lineLimit(1)
                            if isUnread {
                                Circle()
                                    .fill(Color.statusAway)
                                    .frame(width: 9, height: 9)
                            }
                        }

                        (previewText + Text("  (\(timestamp))").font(.system(size: 15, weight: .bold)))
                            .foregroundColor(.textPrimary)
                            .lineLimit(1)
                    }

                    Spacer(minLength: 8)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PressableStyle(scale: 0.99))

            menuGlyph
        }
        .padding(.vertical, 10)
    }

    private var previewText: Text {
        switch preview {
        case .incoming(let body):
            return Text(body).font(.bodyMD)
        case .sent(let prefix, let body):
            return Text("\(prefix) ").font(.system(size: 16, weight: .bold))
                + Text(body).font(.bodyMD)
        case .reaction(let body):
            return Text(body).font(.system(size: 16).italic())
        }
    }

    private var menuGlyph: some View {
        Button(action: onMenu) {
            VStack(spacing: 6) {
                HStack(spacing: 6) { dot; dot }
                HStack(spacing: 6) { dot; dot }
            }
            .padding(10)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.88))
    }

    private var dot: some View {
        Circle().fill(Color.textPrimary).frame(width: 5, height: 5)
    }
}
