import SwiftUI

enum AppTab: CaseIterable {
    case home, chat, explore, profile

    var icon: String {
        switch self {
        case .home: return "house"
        case .chat: return "bubble.left"
        case .explore: return "safari"
        case .profile: return "hexagon"
        }
    }
}

/// Floating pill nav bar with active tab elevated as a black circle. §2.7.
struct BottomTabBar: View {
    @Binding var selected: AppTab

    var body: some View {
        HStack {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Spacer()
                Button(action: { selected = tab }) {
                    ZStack {
                        if selected == tab {
                            Circle()
                                .fill(LinearGradient.action)
                                .frame(width: 52, height: 52)
                                .offset(y: -10)
                                .shadow(color: .heraeInk.opacity(0.22), radius: 10, y: 5)
                        }
                        Image(systemName: tab.icon)
                            .foregroundColor(selected == tab ? .textInverse : .textSecondary)
                            .offset(y: selected == tab ? -10 : 0)
                    }
                }
                Spacer()
            }
        }
        .padding(.vertical, 14)
        .animation(.spring(response: 0.32, dampingFraction: 0.78), value: selected)
        .background(.regularMaterial, in: Capsule())
        .cardShadow()
        .padding(.horizontal, Spacing.screenH)
        // The bar floats off the bottom edge; that inset is the bar's own, not
        // each screen's, so call sites don't repeat it. Pair with
        // `Spacing.tabBarClearance` on the scrolling content above it.
        .padding(.bottom, 12)
    }
}
