import SwiftUI

struct HomeView: View {
    @State private var pulseFilter = "All"
    let userName = "Zainab"

    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient.canvas.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header — sits directly on the canvas; the gradient's own
                // cream-to-sage shift is what separates it from the content.
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Hi \(userName)!")
                            .font(.displaySM)
                            .displayTracking(28)
                            .foregroundColor(.textPrimary)
                        Text("Your next connection is waiting.")
                            .font(.bodyMD)
                            .foregroundColor(.textSecondary)
                    }
                    Spacer(minLength: Spacing.stack)
                    DualOrbAvatar(size: 56)
                }
                .padding(.horizontal, Spacing.screenH)
                .padding(.top, 64)
                .padding(.bottom, Spacing.stack)

                ScrollView {
                    VStack(spacing: 20) {
                        // Progress ring — activity summary
                        ProgressRing(
                            segments: [
                                .init(label: "Friends", value: 18, color: .heraeSage),
                                .init(label: "Mentors", value: 2, color: .heraeCream),
                                .init(label: "Mentees", value: 7, color: .heraeOlive)
                            ],
                            centerValue: "27",
                            centerLabel: "Connections"
                        )

                        // Stat trio
                        StatTrioRow(stats: [
                            .init(label: "New Matches", value: "03"),
                            .init(label: "Pending", value: "01"),
                            .init(label: "Active Chats", value: "05")
                        ])
                        .padding(.horizontal, Spacing.screenH)

                        // Today's buddy
                        DetailCardWithIconCTA(
                            icon: "person.crop.circle.badge.checkmark",
                            title: "Today's Buddy",
                            subtitle: "You matched with Aiden — say hi!",
                            action: {}
                        )
                        .padding(.horizontal, Spacing.screenH)

                        // Challenges
                        ModuleCard {
                            Text("Challenges").font(.bodyLG).foregroundColor(.textPrimary)
                            ExpandableDataRow(title: "Coffee Chat Streak", subtitle: "2 of 3 completed", dotColor: .statusAway)
                            ExpandableDataRow(title: "Meet a New Buddy", subtitle: "Not started", dotColor: .statusNone)
                        }
                        .padding(.horizontal, Spacing.screenH)

                        // Campus pulse
                        ModuleCard {
                            Text("Campus Pulse").font(.bodyLG).foregroundColor(.textPrimary)
                            FilterPillGroup(options: ["All", "Events", "Study"], selected: $pulseFilter)
                            ExpandableDataRow(title: "Meet & Mingle — Friday", subtitle: "42 students interested", dotColor: .statusAvailable, showChevron: false)
                        }
                        .padding(.horizontal, Spacing.screenH)

                        Spacer(minLength: Spacing.tabBarClearance)
                    }
                    .padding(.top, 20)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
