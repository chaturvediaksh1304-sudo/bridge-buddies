import SwiftUI

/// Splash — wireframe 1.
///
/// The canvas carries the whole screen: cream at the top where the wordmark
/// sits, settling into sage behind the action. Nothing else competes with the
/// mark, which is the only thing on screen worth looking at.
struct SplashView: View {
    let session: AuthSession

    @State private var showLogin = false

    var body: some View {
        ZStack {
            LinearGradient.canvas.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Wordmark(size: 40, tint: .textPrimary)

                PrimaryButton(title: "Get Started", style: .dark) {
                    showLogin = true
                }
                .padding(.horizontal, Spacing.section + Spacing.screenH)
                .padding(.top, Spacing.section)

                Spacer()
                Spacer()

                Text("Making the first hello effortless.")
                    .font(.bodyMD)
                    .foregroundColor(.textSecondary)
                    .padding(.bottom, Spacing.section + Spacing.stack)
            }
        }
        .navigationDestination(isPresented: $showLogin) { LoginView(session: session) }
    }
}

#Preview {
    NavigationStack { SplashView(session: AuthSession(auth: .development())) }
}
