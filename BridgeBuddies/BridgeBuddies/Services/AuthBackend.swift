import Foundation

/// The seam between the app and whatever actually performs authentication.
///
/// `AuthService` owns the rules (which domains are allowed, how strong a
/// password must be, whether an unverified address may sign in); a backend only
/// performs the operation and translates its own errors into `AuthError`. That
/// split is what lets every rule above be tested without a Firebase project, a
/// network, or a simulator.
protocol AuthBackend: Sendable {
    func signUp(email: String, password: String) async throws -> AuthenticatedUser
    func signIn(email: String, password: String) async throws -> AuthenticatedUser
    func signInWithApple(idToken: String, rawNonce: String) async throws -> AuthenticatedUser
    func sendEmailVerification() async throws
    func sendPasswordReset(email: String) async throws
    func signOut() async throws
}
