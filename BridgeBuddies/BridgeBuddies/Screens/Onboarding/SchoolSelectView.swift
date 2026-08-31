import SwiftUI

/// Onboarding step 3 — pick the university that scopes the rest of the app.
///
/// The list card is the screen: the wordmark and title sit above it as a thin
/// header, and everything else gets out of its way. Forward stays disabled
/// until a school is actually chosen, because "no school" is not a state the
/// next screen can render.
struct SchoolSelectView: View {
    @State private var query = ""
    @State private var selected: String?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var onContinue: (String) -> Void = { _ in }

    private var filtered: [String] {
        let q = query.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return Self.schools }
        return Self.schools.filter { $0.localizedCaseInsensitiveContains(q) }
    }

    var body: some View {
        ZStack {
            LinearGradient.canvas.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Wordmark(size: 22)
                    .frame(maxWidth: .infinity)

                Text("Select your school")
                    .font(.displayMD)
                    .foregroundColor(.textPrimary)
                    .padding(.top, 56)
                    .padding(.bottom, Spacing.section)

                SearchActionBar(
                    text: $query,
                    placeholder: "Drop down from the list",
                    trailingIcon: "chevron.down",
                    onTrailingTap: { query = "" }
                )

                ListCard {
                    if filtered.isEmpty {
                        Text("No schools match “\(query)”")
                            .font(.bodyMD)
                            .foregroundColor(.textSecondary)
                            .padding(.vertical, 7)
                    } else {
                        ForEach(filtered, id: \.self) { school in
                            PlainListRow(title: school, isSelected: selected == school) {
                                selected = school
                            }
                        }
                    }
                }
                .frame(maxHeight: .infinity)
                .padding(.top, Spacing.stack)
                .animation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 1.0),
                           value: filtered)

                HStack {
                    CircularNavButton(direction: .back) { dismiss() }
                    Spacer()
                    CircularNavButton(direction: .forward, isEnabled: selected != nil) {
                        if let selected { onContinue(selected) }
                    }
                }
                .padding(.top, Spacing.section)
            }
            .padding(.horizontal, Spacing.screenH)
            .padding(.top, Spacing.stack)
            .padding(.bottom, Spacing.stack)
        }
        .navigationBarBackButtonHidden(true)
    }

    private static let schools = [
        "Arizona State University",
        "Boston University",
        "Brown University",
        "Carnegie Mellon University",
        "Central Michigan University",
        "Columbia University",
        "Cornell University",
        "Dartmouth College",
        "Duke University",
        "Georgia Institute of Technology",
        "Harvard University",
        "Johns Hopkins University",
        "Massachusetts Institute of Technology",
        "Michigan State University",
        "New York University",
        "Northeastern University",
        "Ohio State University",
        "Pennsylvania State University",
        "Princeton University",
        "Purdue University",
        "Rice University",
        "Rutgers University",
        "Stanford University",
        "University of Michigan"
    ]
}

#Preview {
    NavigationStack { SchoolSelectView() }
}
