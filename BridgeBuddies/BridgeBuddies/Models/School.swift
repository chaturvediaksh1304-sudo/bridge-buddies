import Foundation

/// A school a student can belong to, and the email domain that proves it.
///
/// The domain lives with the school rather than in the auth layer, so
/// supporting another campus is a data change and not a code change — which is
/// what the PRD means by "architecture supports future multi-school".
struct School: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let emailDomain: String
}

extension School {
    static let centralMichigan = School(
        id: "cmich", name: "Central Michigan University", emailDomain: "cmich.edu"
    )

    /// What School Select offers.
    ///
    /// ⚠️ The PRD scopes v1 to CMU only, but wireframe 2.2 draws this full list
    /// and the screen was built from it. Both are shipped: swap `catalog` for
    /// `v1Catalog` to enforce the PRD. Flagged for a decision rather than
    /// silently picking one.
    static let catalog: [School] = [
        .init(id: "asu", name: "Arizona State University", emailDomain: "asu.edu"),
        .init(id: "bu", name: "Boston University", emailDomain: "bu.edu"),
        .init(id: "brown", name: "Brown University", emailDomain: "brown.edu"),
        .init(id: "cmu", name: "Carnegie Mellon University", emailDomain: "cmu.edu"),
        centralMichigan,
        .init(id: "columbia", name: "Columbia University", emailDomain: "columbia.edu"),
        .init(id: "cornell", name: "Cornell University", emailDomain: "cornell.edu"),
        .init(id: "dartmouth", name: "Dartmouth College", emailDomain: "dartmouth.edu"),
        .init(id: "duke", name: "Duke University", emailDomain: "duke.edu"),
        .init(id: "gatech", name: "Georgia Institute of Technology", emailDomain: "gatech.edu"),
        .init(id: "harvard", name: "Harvard University", emailDomain: "harvard.edu"),
        .init(id: "jhu", name: "Johns Hopkins University", emailDomain: "jhu.edu"),
        .init(id: "mit", name: "Massachusetts Institute of Technology", emailDomain: "mit.edu"),
        .init(id: "msu", name: "Michigan State University", emailDomain: "msu.edu"),
        .init(id: "nyu", name: "New York University", emailDomain: "nyu.edu"),
        .init(id: "northeastern", name: "Northeastern University", emailDomain: "northeastern.edu"),
        .init(id: "osu", name: "Ohio State University", emailDomain: "osu.edu"),
        .init(id: "psu", name: "Pennsylvania State University", emailDomain: "psu.edu"),
        .init(id: "princeton", name: "Princeton University", emailDomain: "princeton.edu"),
        .init(id: "purdue", name: "Purdue University", emailDomain: "purdue.edu"),
        .init(id: "rice", name: "Rice University", emailDomain: "rice.edu"),
        .init(id: "rutgers", name: "Rutgers University", emailDomain: "rutgers.edu"),
        .init(id: "stanford", name: "Stanford University", emailDomain: "stanford.edu"),
        .init(id: "umich", name: "University of Michigan", emailDomain: "umich.edu")
    ]

    /// The PRD's MVP scope.
    static let v1Catalog: [School] = [centralMichigan]
}

extension EmailDomainValidator {
    init(school: School) {
        self.init(allowedDomains: [school.emailDomain])
    }
}
