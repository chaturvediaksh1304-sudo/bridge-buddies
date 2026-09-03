import Foundation

/// Applies the app's auth rules, then delegates to a backend.
///
/// Every rule runs *before* the backend is called, so an address from the wrong
/// domain or a password that can't succeed never becomes a network round-trip —
/// and never becomes a Firebase account that then has to be cleaned up.
struct AuthService: Sendable {
    private let backend: any AuthBackend
    private let validator: EmailDomainValidator

    init(backend: any AuthBackend, validator: EmailDomainValidator) {
        self.backend = backend
        self.validator = validator
    }

    @discardableResult
    func signUp(email: String, password: String) async throws -> AuthenticatedUser {
        let email = try allowedAddress(email)
        let failures = PasswordPolicy.failures(for: password)
        guard failures.isEmpty else { throw AuthError.weakPassword(failures) }

        let user = try await backend.signUp(email: email, password: password)
        try await backend.sendEmailVerification()
        return user
    }

    func signIn(email: String, password: String) async throws -> AuthenticatedUser {
        let email = try allowedAddress(email)
        let user = try await backend.signIn(email: email, password: password)
        // The domain check only proves the address *looks* like a school one.
        // Confirming the inbox is what proves the person holds it.
        guard user.isEmailVerified else { throw AuthError.emailNotVerified }
        return user
    }

    /// Apple Sign-In deliberately skips the domain rule: Hide My Email issues
    /// `@privaterelay.appleid.com` addresses, so enforcing it here would reject
    /// every relay user. School affiliation for these accounts has to be
    /// established separately — see the note in Phases.md.
    func signInWithApple(idToken: String, rawNonce: String) async throws -> AuthenticatedUser {
        try await backend.signInWithApple(idToken: idToken, rawNonce: rawNonce)
    }

    func sendPasswordReset(email: String) async throws {
        try await backend.sendPasswordReset(email: allowedAddress(email))
    }

    func signOut() async throws {
        try await backend.signOut()
    }

    private func allowedAddress(_ email: String) throws -> String {
        let email = EmailDomainValidator.normalized(email)
        guard EmailDomainValidator.domain(of: email) != nil else { throw AuthError.invalidEmail }
        guard validator.isAllowed(email) else { throw AuthError.disallowedDomain }
        return email
    }
}
