import SwiftUI

/// Login — wireframe 2.1.
///
/// The screen is three bands with air between them, not one evenly-spaced
/// column: a dark title block that the back button sits on top of, the credential
/// pair floating in the middle, and the commit zone (CTA + sign-up) low on the
/// screen with the wordmark anchored below it. The gaps between those bands are
/// flexible, so the layout keeps its proportions rather than its pixel offsets
/// as the device changes.
struct LoginView: View {
    @State private var model: LoginViewModel

    @Environment(\.dismiss) private var dismiss

    var onSignUp: () -> Void = {}

    init(auth: AuthService = .development(), onSignUp: @escaping () -> Void = {}) {
        _model = State(initialValue: LoginViewModel(auth: auth))
        self.onSignUp = onSignUp
    }

    var body: some View {
        ZStack {
            LinearGradient.canvas.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                credentials
                    .padding(.horizontal, Spacing.screenH)
                    .padding(.top, Spacing.section + Spacing.stack)

                Spacer(minLength: Spacing.section)

                commit
                    .padding(.horizontal, Spacing.screenH)

                Spacer(minLength: Spacing.section)

                Wordmark(size: 26, tint: .textSecondary)
                    .padding(.bottom, Spacing.section)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Bands

    /// Back control and title on the bare canvas. The wireframe drew a darker
    /// block behind the title, which only worked because the page under it was
    /// a different grey; on one continuous cream-to-sage ground there is
    /// nothing for that block to contrast against, so the title carries the
    /// top of the screen on its own.
    private var header: some View {
        ZStack(alignment: .topLeading) {
            Text("Login")
                .font(.displayMD)
                .displayTracking(32)
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.top, 40)

            CircularNavButton(direction: .back) { dismiss() }
                .padding(.leading, Spacing.screenH)
        }
        .frame(height: 148, alignment: .top)
    }

    private var credentials: some View {
        VStack(spacing: Spacing.stack) {
            InputPill(label: "Email", text: $model.email, layout: .stacked)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .textContentType(.username)

            InputPill(label: "Password", text: $model.password, layout: .stacked, isSecure: true)
                .textContentType(.password)

            if let errorMessage = model.errorMessage {
                Text(errorMessage)
                    .font(.bodySM)
                    .foregroundColor(.statusBusy)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 8)
                    .transition(.opacity)
            }

            HStack(spacing: Spacing.stack) {
                CheckboxToggle(isOn: $model.rememberMe, label: "Remember Me")

                Spacer(minLength: 0)

                Button { Task { await model.sendPasswordReset() } } label: {
                    Text("Forgot Password?")
                        .font(.bodyMD)
                        .foregroundColor(.textSecondary)
                }
                .buttonStyle(PressableStyle(scale: 0.95))
            }
            .padding(.top, 4)
        }
        .animation(.spring(response: 0.35, dampingFraction: 1.0), value: model.errorMessage)
    }

    private var commit: some View {
        VStack(spacing: Spacing.stack) {
            PrimaryButton(
                title: model.isSubmitting ? "Signing in…" : "Log in",
                style: .dark,
                font: .displayFont(size: 26)
            ) {
                Task { await model.logIn() }
            }
            .opacity(model.canSubmit ? 1 : 0.55)
            .disabled(!model.canSubmit)
            .animation(.spring(response: 0.35, dampingFraction: 1.0), value: model.canSubmit)

            HStack(spacing: 5) {
                Text("Don't have an account?")
                    .font(.bodyMD)
                    .foregroundColor(.textSecondary)

                Button(action: onSignUp) {
                    Text("Sign up")
                        .font(.bodyMD)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                }
                .buttonStyle(PressableStyle(scale: 0.95))
            }
        }
    }
}

#Preview {
    NavigationStack { LoginView() }
}
