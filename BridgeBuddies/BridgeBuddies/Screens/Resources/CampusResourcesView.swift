import SwiftUI

/// Campus Resources — the alphabetical index of school support services.
///
/// Deliberately motionless: this list carries crisis and safety lines, so
/// filtering is instant and nothing animates in or out. The only movement on
/// the screen is the press feedback already inside `PlainListRow`.
struct CampusResourcesView: View {
    /// Tapping a row would open the resource's URL; no destination exists yet.
    var onSelect: (String) -> Void = { _ in }

    @State private var query = ""
    @State private var tab: AppTab = .explore

    private static let resources = [
        "24/7 Resources for Students in Crisis",
        "988 Suicide and Crisis Lifeline",
        "Alcohol and Other Drugs Self-Help Resources",
        "Campus Safety",
        "Center for Community Counseling and Development",
        "Center for Student Inclusion and Diversity (CSID)",
        "Certified Testing Center",
        "CMCREW",
        "CMU CARES",
        "CMU Police Department",
        "Counseling Center",
        "Crisis Text Line",
        "Health and Well-Being",
        "Health and Wellness",
        "Health Insurance for International Students",
        "Listening Ear Crisis Center",
        "Mental Health Resources",
        "Office of Civil Rights and Institutional Equity (OCRIE)",
        "Office of LGBTQ Services",
        "Office of Student Conduct",
        "Self-Help Resources (Counseling Center)",
        "Sexual Aggression Peer Advocates (SAPA)",
        "Student Disability Services",
        "Student Food Pantry",
        "Student Health Resources",
        "Student Health Services",
        "Ten16 Recovery Network",
        "Title IX Sexual and Gender-Based Misconduct",
        "University and Community Resources",
        "University Ombuds Office",
        "University Recreation"
    ]

    private var matches: [String] {
        let q = query.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return Self.resources }
        return Self.resources.filter { $0.localizedCaseInsensitiveContains(q) }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient.canvas.ignoresSafeArea()

            VStack(alignment: .leading, spacing: Spacing.stack) {
                RuledLabel(text: "Central Michigan University", tint: .heraeOlive)
                    .padding(.top, Spacing.stack)

                Text("Campus Resources")
                    .font(.displayMD)
                    .foregroundColor(.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, Spacing.section)

                SearchActionBar(text: $query)

                ListCard {
                    if matches.isEmpty {
                        Text("No resources match “\(query)”.")
                            .font(.bodyMD)
                            .foregroundColor(.textSecondary)
                            .padding(.vertical, 7)
                    } else {
                        ForEach(matches, id: \.self) { name in
                            PlainListRow(title: name) { onSelect(name) }
                        }
                    }
                }
                .padding(.bottom, Spacing.tabBarClearance)
            }
            .padding(.horizontal, Spacing.screenH)

            BottomTabBar(selected: $tab)
        }
    }
}

#Preview {
    CampusResourcesView()
}
