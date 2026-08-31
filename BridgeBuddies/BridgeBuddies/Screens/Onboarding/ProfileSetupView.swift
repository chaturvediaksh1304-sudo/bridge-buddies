import SwiftUI

/// Onboarding step 4 — the long form. Wireframe 2.3.
///
/// The background flips from the neutral gradient to the brand maroon here: this
/// is the first screen where the user is building *their* profile rather than
/// getting through auth chrome, and the colour shift marks that.
///
/// The twelve fields are not one list. They are five short sections — identity,
/// contact, credentials, personal, context — and the spacing says so: fields
/// inside a section sit `fieldGap` apart, sections `groupGap`. Helper text stays
/// owned by its field (the pill components draw it at 6pt), so it never floats
/// between two groups.
struct ProfileSetupView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var userName = ""
    @State private var schoolEmail = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var dateOfBirth = ""
    @State private var bio = ""
    @State private var location = ""
    @State private var major = ""
    @State private var standing = ""

    @Environment(\.dismiss) private var dismiss

    /// Tight rhythm inside a group.
    private let fieldGap: CGFloat = 12
    /// Breathing room between groups — the whole point of the layout.
    private let groupGap = Spacing.section

    private let bioLimit = 200

    private var canContinue: Bool {
        ![firstName, lastName, userName, schoolEmail, phone,
          password, confirmPassword, dateOfBirth, bio]
            .contains { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    var body: some View {
        ZStack {
            LinearGradient.canvas.ignoresSafeArea()

            VStack(spacing: 0) {
                Text("Profile Setup")
                    .font(.displayMD)
                    .foregroundColor(.textPrimary)
                    .padding(.bottom, groupGap)

                ScrollView {
                    VStack(spacing: groupGap) {
                        group {
                            InputPill(label: "First Name*", text: $firstName)
                            InputPill(label: "Last Name*", text: $lastName)
                            InputPill(label: "User Name*", text: $userName)
                        }

                        group {
                            InputPill(label: "School Email*", text: $schoolEmail)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                            InputPill(label: "Phone No.*", text: $phone)
                                .keyboardType(.phonePad)
                        }

                        InputPillPair(
                            topLabel: "Password*", topText: $password,
                            bottomLabel: "Confirm It*", bottomText: $confirmPassword,
                            helperText: "Be at least 8 characters long; must include one uppercase letter; must include one lowercase letter; must include one number; must include one special character"
                        )

                        group {
                            InputPill(label: "Date of Birth*", text: $dateOfBirth)
                            InputPill(
                                label: "Bio*", text: $bio, isMultiline: true,
                                helperText: "A short intro about you — interests, vibes, or what you're looking for\nCharacter limit: Max \(bioLimit) characters"
                            )
                            .onChange(of: bio) { _, new in
                                if new.count > bioLimit { bio = String(new.prefix(bioLimit)) }
                            }
                        }

                        group {
                            InputPill(label: "Location", text: $location)
                            InputPill(label: "Major", text: $major)
                            InputPill(label: "Standing", text: $standing)
                        }
                    }
                    .padding(.horizontal, Spacing.screenH)
                    .padding(.bottom, groupGap)
                }
                .scrollDismissesKeyboard(.interactively)

                footer
            }
            .padding(.top, Spacing.stack)
        }
    }

    private func group<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(spacing: fieldGap, content: content)
    }

    private var footer: some View {
        HStack {
            CircularNavButton(direction: .back) { dismiss() }
            Spacer(minLength: Spacing.stack)
            LegalLinksRow(links: ["Privacy Policy", "Terms of Use"])
            Spacer(minLength: Spacing.stack)
            CircularNavButton(direction: .forward, isEnabled: canContinue) {}
                .animation(.spring(response: 0.35, dampingFraction: 1.0), value: canContinue)
        }
        .padding(.horizontal, Spacing.screenH)
        .padding(.top, Spacing.stack)
        .padding(.bottom, Spacing.stack)
    }
}

#Preview {
    ProfileSetupView()
}
