import SwiftUI

/// Profile — main tab (wireframe 6.1).
///
/// Three zones, deliberately not evenly spaced: the two cards sit close
/// together as one block of navigation, then the brand/legal footer floats in
/// noticeably more open air, then Sign out sits apart again as the last thing
/// on the screen. The two flexible spacers are what carry that — the layout is
/// fixed-height by design (nothing here scrolls), so they absorb whatever the
/// device gives us and keep the footer breathing.
struct ProfileView: View {
    var name: String = "Zainab"
    var subtitle: String = "Class of 2026 | Senior"
    var friends: String = "18"
    var mentors: String = "02"
    var mentees: String = "07"

    var onOverflow: () -> Void = {}
    var onPrivacySettings: () -> Void = {}
    var onHelp: () -> Void = {}
    var onChangeLanguage: () -> Void = {}
    var onLegalLink: (String) -> Void = { _ in }
    var onSignOut: () -> Void = {}


    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient.canvas.ignoresSafeArea()

            VStack(spacing: 0) {
                identityCard
                    .padding(.bottom, Spacing.stack)

                settingsCard

                Spacer(minLength: Spacing.section)

                VStack(spacing: Spacing.stack) {
                    Wordmark(size: 42, tint: .textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)

                    LegalLinksRow(
                        links: ["Privacy Policy", "Accessibility Statement", "Terms of Use"],
                        tint: .textPrimary,
                        onTap: onLegalLink
                    )
                    .padding(.horizontal, Spacing.screenH)
                }

                Spacer(minLength: Spacing.section)

                PrimaryButton(title: "Sign out", style: .light, action: onSignOut)
                    .padding(.horizontal, Spacing.screenH)
            }
            .padding(.top, Spacing.stack)
            .padding(.bottom, Spacing.tabBarClearance)
        }
    }

    // MARK: - Identity

    private var identityCard: some View {
        ListCard(hugsContent: true) {
            HStack(alignment: .top, spacing: Spacing.stack) {
                DualOrbAvatar(size: 62)

                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.displayMD)
                        .foregroundColor(.textPrimary)
                    Text(subtitle)
                        .font(.bodyMD)
                        .foregroundColor(.textPrimary)
                }
                .padding(.top, 4)

                Spacer(minLength: Spacing.stack)

                Button(action: onOverflow) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.textPrimary)
                        .rotationEffect(.degrees(90))
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PressableStyle(scale: 0.9))
                .accessibilityLabel("More profile options")
            }

            Rectangle()
                .fill(Color.hairline)
                .frame(height: 1)
                .padding(.vertical, Spacing.stack)

            StatTrioRow(
                stats: [
                    .init(label: "Friends", value: friends),
                    .init(label: "Mentors", value: mentors),
                    .init(label: "Mentees", value: mentees)
                ],
                style: .plain
            )
            .padding(.bottom, 4)
        }
        .padding(.horizontal, Spacing.screenH)
    }

    // MARK: - Settings

    private var settingsCard: some View {
        ListCard(hugsContent: true) {
            SettingsMenuRow(icon: "pencil", title: "Edit Profile") {
                // Routes to the Edit Profile screen, which doesn't exist yet.
            }
            SettingsMenuRow(icon: "lock", title: "Privacy Settings", action: onPrivacySettings)
            SettingsMenuRow(icon: "questionmark", title: "Help", action: onHelp)
            SettingsMenuRow(icon: "globe", title: "Change Language", action: onChangeLanguage)
        }
        .padding(.horizontal, Spacing.screenH)
    }
}

#Preview {
    ProfileView()
}
