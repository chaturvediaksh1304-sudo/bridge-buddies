import Observation

/// The app's single source of truth for who is signed in.
///
/// The root view renders from `state` rather than from whatever screen happened
/// to be on-screen last, so a relaunch lands where the *session* says it should.
/// That is also why `.loading` exists: restoring is asynchronous, and without a
/// distinct state the root would flash Splash before correcting itself.
@MainActor
@Observable
final class AuthSession {
    enum State: Equatable {
        case loading
        case signedOut
        case signedIn(AuthenticatedUser)
    }

    private(set) var state: State = .loading

    private let auth: AuthService

    init(auth: AuthService) {
        self.auth = auth
    }

    /// Called once when the root appears.
    func start() async {
        state = await auth.restoreSession().map(State.signedIn) ?? .signedOut
    }

    func signIn(email: String, password: String) async throws {
        state = .signedIn(try await auth.signIn(email: email, password: password))
    }

    /// Sign-up deliberately does *not* sign the user in: the account starts
    /// unverified, and `signIn` would reject it. The session stays signed out
    /// until they confirm the address.
    func signUp(email: String, password: String) async throws {
        _ = try await auth.signUp(email: email, password: password)
        state = .signedOut
    }

    func sendPasswordReset(email: String) async throws {
        try await auth.sendPasswordReset(email: email)
    }

    func signOut() async {
        // A backend failure still ends the local session — leaving someone
        // stuck signed in because the network blipped is the worse outcome.
        try? await auth.signOut()
        state = .signedOut
    }
}
