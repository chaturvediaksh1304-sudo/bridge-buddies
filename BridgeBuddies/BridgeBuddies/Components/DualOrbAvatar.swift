import SwiftUI

/// Signature avatar: two overlapping gradient circles. §2.8.
struct DualOrbAvatar: View {
    var size: CGFloat = 64
    var bigColor: Color = .heraeOlive
    var smallColor: Color = .heraeCream

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Circle()
                .fill(bigColor.gradient)
                .frame(width: size, height: size)
            Circle()
                .fill(smallColor)
                .frame(width: size * 0.4, height: size * 0.4)
                .offset(x: -size * 0.08, y: size * 0.08)
        }
        .frame(width: size * 1.15, height: size * 1.15, alignment: .topTrailing)
    }
}

enum PresenceStatus {
    case available, busy, away, none

    /// Display name for presence pickers. `.away` reads as "Off Campus" —
    /// the wireframes' wording for the same state the enum calls away.
    var label: String {
        switch self {
        case .available: return "Available"
        case .busy: return "Busy"
        case .away: return "Off Campus"
        case .none: return "No Status"
        }
    }

    var color: Color {
        switch self {
        case .available: return .statusAvailable
        case .busy: return .statusBusy
        case .away: return .statusAway
        case .none: return .statusNone
        }
    }
}

/// Small colored dot overlaid on an avatar. §2.9.
struct StatusDot: View {
    let status: PresenceStatus
    var size: CGFloat = 14

    var body: some View {
        Circle()
            .fill(status.color)
            .frame(width: size, height: size)
            .overlay(Circle().stroke(Color.surfaceCardPure, lineWidth: 2))
    }
}
