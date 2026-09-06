import Foundation

/// An `AuthBackend` that keeps accounts in memory for the lifetime of the process.
///
/// Not a test double — the tests use their own fake. This exists so the app runs
/// end-to-end in the simulator before a Firebase project exists: domain rules,
/// password rules and the unverified-email gate all behave for real, against
/// accounts that vanish on relaunch.
///
/// Swap it for `FirebaseAuthBackend` once the SDK is in the target.
actor InMemoryAuthBackend: AuthBackend {
    private struct Account {
        let id: String
        let password: String
        var isEmailVerified: Bool
    }

    private var accounts: [String: Account] = [:]
    private var signedInEmail: String?

    /// Verification emails obviously can't be sent, so this decides whether a
    /// new account starts out verified. `false` exercises the real gate; `true`
    /// skips straight past it when you're demoing a later screen.
    private let autoVerify: Bool

    init(autoVerify: Bool = false) {
        self.autoVerify = autoVerify
    }

    func signUp(email: String, password: String) async throws -> AuthenticatedUser {
        guard accounts[email] == nil else { throw AuthError.emailAlreadyInUse }
        let account = Account(id: UUID().uuidString, password: password, isEmailVerified: autoVerify)
        accounts[email] = account
        signedInEmail = email
        return AuthenticatedUser(id: account.id, email: email, isEmailVerified: account.isEmailVerified)
    }

    func signIn(email: String, password: String) async throws -> AuthenticatedUser {
        guard let account = accounts[email] else { throw AuthError.userNotFound }
        guard account.password == password else { throw AuthError.wrongPassword }
        signedInEmail = email
        return AuthenticatedUser(id: account.id, email: email, isEmailVerified: account.isEmailVerified)
    }

    func signInWithApple(idToken: String, rawNonce: String) async throws -> AuthenticatedUser {
        let email = "demo@privaterelay.appleid.com"
        let account = accounts[email] ?? Account(id: UUID().uuidString, password: "", isEmailVerified: true)
        accounts[email] = account
        signedInEmail = email
        return AuthenticatedUser(id: account.id, email: email, isEmailVerified: true)
    }

    func sendEmailVerification() async throws {
        guard let email = signedInEmail else { throw AuthError.userNotFound }
        // Stands in for the user clicking the link in their inbox.
        accounts[email]?.isEmailVerified = true
    }

    func sendPasswordReset(email: String) async throws {
        guard accounts[email] != nil else { throw AuthError.userNotFound }
    }

    func signOut() async throws { signedInEmail = nil }

    /// Nothing survives a relaunch, so there is never a session to restore.
    func restoreSession() async throws -> AuthenticatedUser? { nil }
}
