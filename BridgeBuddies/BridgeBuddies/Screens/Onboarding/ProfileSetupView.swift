import SwiftUI

/// Profile Setup — wireframe 2.3.
///
/// The twelve fields are not one list. They are five short sections — identity,
/// contact, credentials, personal, context — and the spacing says so: fields
/// inside a section sit `fieldGap` apart, sections `groupGap`. Helper text stays
/// owned by its field, so a rule never floats between two groups.
///
/// Submitting creates the auth account. The session deliberately stays signed
/// out afterwards: the address is unverified, and `signIn` would reject it.
struct ProfileSetupView: View {
    @State private var model: ProfileSetupViewModel

    @Environment(\.dismiss) private var dismiss

    init(session: AuthSession) {
        _model = State(initialValue: ProfileSetupViewModel(session: session))
    }

    /// Tight rhythm inside a group.
    private let fieldGap: CGFloat = 12
    /// Breathing room between groups — the whole point of the layout.
    private let groupGap = Spacing.section

    var body: some View {
        ZStack {
            LinearGradient.canvas.ignoresSafeArea()

            VStack(spacing: 0) {
                Text("Profile Setup")
                    .font(.displayMD)
                    .displayTracking(32)
                    .foregroundColor(.textPrimary)
                    .padding(.bottom, groupGap)

                ScrollView {
                    VStack(spacing: groupGap) {
                        group {
                            InputPill(label: "First Name*", text: $model.draft.firstName)
                            InputPill(label: "Last Name*", text: $model.draft.lastName)
                            InputPill(label: "User Name*", text: $model.draft.userName)
                        }

                        group {
                            InputPill(
                                label: "School Email*", text: $model.draft.email,
                                helperText: model.emailHelper
                            )
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            InputPill(label: "Phone No.*", text: $model.draft.phone)
                                .keyboardType(.phonePad)
                        }

                        InputPillPair(
                            topLabel: "Password*", topText: $model.draft.password,
                            bottomLabel: "Confirm It*", bottomText: $model.draft.confirmPassword,
                            helperText: model.passwordHelper
                        )

                        group {
                            InputPill(label: "Date of Birth*", text: $model.draft.dateOfBirth)
                            InputPill(
                                label: "Bio*", text: $model.draft.bio, isMultiline: true,
                                helperText: model.bioHelper
                            )
                        }

                        group {
                            InputPill(label: "Location", text: $model.draft.location)
                            InputPill(label: "Major", text: $model.draft.major)
                            InputPill(label: "Standing", text: $model.draft.standing)
                        }

                        status
                    }
                    .padding(.horizontal, Spacing.screenH)
                    .padding(.bottom, groupGap)
                    .animation(.spring(response: 0.35, dampingFraction: 1.0), value: model.didCreateAccount)
                }
                .scrollDismissesKeyboard(.interactively)

                footer
            }
            .padding(.top, Spacing.stack)
        }
        .navigationBarBackButtonHidden(true)
    }

    private func group<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(spacing: fieldGap, content: content)
    }

    @ViewBuilder
    private var status: some View {
        if model.didCreateAccount {
            Text("Account created. Confirm your email, then log in.")
                .font(.bodyMD)
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else if let errorMessage = model.errorMessage {
            Text(errorMessage)
                .font(.bodySM)
                .foregroundColor(.statusBusy)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var footer: some View {
        HStack {
            CircularNavButton(direction: .back) { dismiss() }
            Spacer(minLength: Spacing.stack)
            LegalLinksRow(links: ["Privacy Policy", "Terms of Use"])
            Spacer(minLength: Spacing.stack)
            CircularNavButton(direction: .forward, isEnabled: model.canSubmit) {
                Task { await model.submit() }
            }
            .animation(.spring(response: 0.35, dampingFraction: 1.0), value: model.canSubmit)
        }
        .padding(.horizontal, Spacing.screenH)
        .padding(.vertical, Spacing.stack)
    }
}

#Preview {
    NavigationStack { ProfileSetupView(session: AuthSession(auth: .development())) }
}
