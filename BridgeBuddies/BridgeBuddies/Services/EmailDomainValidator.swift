import Foundation

/// Gates sign-up to a school's own email domain.
///
/// Subdomains count — universities routinely hand out `mail.<school>.edu`
/// addresses, and nobody outside the school can register one. A domain that
/// merely *ends with* the school's name does not: `cmich.edu.attacker.com` and
/// `notcmich.edu` are both rejected, which is the whole point of the leading dot.
struct EmailDomainValidator: Sendable {
    let allowedDomains: [String]

    init(allowedDomains: [String]) {
        self.allowedDomains = allowedDomains.map { $0.lowercased() }
    }

    func isAllowed(_ email: String) -> Bool {
        guard let domain = Self.domain(of: email) else { return false }
        return allowedDomains.contains { domain == $0 || domain.hasSuffix("." + $0) }
    }

    /// Lowercased and trimmed. Addresses are compared and stored in this form so
    /// the same person can't end up with two accounts differing only in case.
    static func normalized(_ email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    /// The domain part, or nil if the address isn't well-formed enough to have
    /// one. Not a full RFC 5322 parse — the verification email is what actually
    /// proves an address works; this only rejects the obviously broken.
    static func domain(of email: String) -> String? {
        let email = normalized(email)
        guard !email.isEmpty,
              !email.contains(where: \.isWhitespace) else { return nil }

        let parts = email.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2 else { return nil }

        let local = parts[0], domain = parts[1]
        guard !local.isEmpty, !domain.isEmpty,
              !local.contains(".."), !domain.contains(".."),
              !domain.hasPrefix("."), !domain.hasSuffix("."),
              domain.contains(".") else { return nil }

        return String(domain)
    }
}
