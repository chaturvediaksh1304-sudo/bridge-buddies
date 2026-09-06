import Foundation

/// Everything Profile Setup collects, and the rules that decide whether it can
/// be submitted.
///
/// A value type rather than state scattered across the view, so the rules are
/// testable on their own. Only `email` and `password` reach auth today — the
/// rest is profile data with nowhere to go until Firestore lands in Phase 2,
/// which is why it is kept together here rather than thrown away.
struct ProfileDraft: Equatable, Sendable {
    var firstName = ""
    var lastName = ""
    var userName = ""
    var email = ""
    var phone = ""
    var password = ""
    var confirmPassword = ""
    var dateOfBirth = ""
    var bio = ""
    var location = ""
    var major = ""
    var standing = ""

    static let bioLimit = 200
}

extension ProfileDraft {
    enum Issue: Equatable, Sendable {
        case invalidEmail
        case disallowedDomain
        case weakPassword([PasswordPolicy.Failure])
        case passwordsDontMatch
        case bioTooLong(limit: Int)

        var message: String {
            switch self {
            case .invalidEmail: return "That doesn't look like a valid email address."
            case .disallowedDomain: return "Use your school email address."
            case .weakPassword(let failures): return failures.map(\.message).joined(separator: " ")
            case .passwordsDontMatch: return "Passwords don't match."
            case .bioTooLong(let limit): return "Keep your bio under \(limit) characters."
            }
        }
    }

    /// The starred fields in wireframe 2.3. Location, Major and Standing are not
    /// starred and are genuinely optional.
    var hasAllRequiredFields: Bool {
        ![firstName, lastName, userName, email, phone,
          password, confirmPassword, dateOfBirth, bio]
            .contains { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    var normalizedEmail: String {
        EmailDomainValidator.normalized(email)
    }

    func issues(validatedBy validator: EmailDomainValidator) -> [Issue] {
        var issues: [Issue] = []

        if !email.isEmpty {
            if EmailDomainValidator.domain(of: email) == nil {
                issues.append(.invalidEmail)
            } else if !validator.isAllowed(email) {
                issues.append(.disallowedDomain)
            }
        }

        if !password.isEmpty {
            let failures = PasswordPolicy.failures(for: password)
            if !failures.isEmpty {
                issues.append(.weakPassword(failures))
            } else if !confirmPassword.isEmpty && password != confirmPassword {
                // Only once the password itself is valid — two complaints about
                // the same field at once reads as noise.
                issues.append(.passwordsDontMatch)
            }
        }

        if bio.count > Self.bioLimit {
            issues.append(.bioTooLong(limit: Self.bioLimit))
        }

        return issues
    }
}
