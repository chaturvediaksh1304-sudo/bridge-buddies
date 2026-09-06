import Testing
@testable import BridgeBuddies

@Suite("Auth session")
@MainActor
struct AuthSessionTests {
    private func makeSession(
        restoring user: AuthenticatedUser? = nil
    ) -> (AuthSession, FakeAuthBackend) {
        let backend = FakeAuthBackend(restoring: user)
        let service = AuthService(
            backend: backend,
            validator: EmailDomainValidator(allowedDomains: ["cmich.edu"])
        )
        return (AuthSession(auth: service), backend)
    }

    @Test("starts in loading so the root never flashes the wrong screen")
    func startsLoading() {
        let (session, _) = makeSession()
        #expect(session.state == .loading)
    }

    @Test("resolves to signed out when there is nothing to restore")
    func resolvesSignedOut() async {
        let (session, _) = makeSession(restoring: nil)
        await session.start()
        #expect(session.state == .signedOut)
    }

    @Test("resolves to signed in when a verified session is restored")
    func resolvesSignedIn() async {
        let user = AuthenticatedUser.stub(isEmailVerified: true)
        let (session, _) = makeSession(restoring: user)
        await session.start()
        #expect(session.state == .signedIn(user))
    }

    @Test("treats a restored but unverified session as signed out")
    func unverifiedRestoreIsSignedOut() async {
        // Letting an unverified account through here would route straight past
        // the gate that `signIn` enforces.
        let (session, _) = makeSession(restoring: .stub(isEmailVerified: false))
        await session.start()
        #expect(session.state == .signedOut)
    }

    @Test("signing in moves the session to signed in")
    func signInUpdatesState() async throws {
        let (session, _) = makeSession()
        await session.start()
        try await session.signIn(email: "zaina1z@cmich.edu", password: "Passw0rd!")
        #expect(session.state == .signedIn(.stub()))
    }

    @Test("a failed sign-in leaves the session signed out")
    func failedSignInKeepsSignedOut() async {
        let (session, backend) = makeSession()
        await session.start()
        await #expect(throws: AuthError.disallowedDomain) {
            try await session.signIn(email: "someone@gmail.com", password: "Passw0rd!")
        }
        #expect(session.state == .signedOut)
        #expect(await backend.recorded().isEmpty)
    }

    @Test("signing up leaves the session signed out until the address is confirmed")
    func signUpDoesNotSignIn() async throws {
        // The account starts unverified, so signing the user straight in would
        // walk past the gate `signIn` enforces.
        let (session, backend) = makeSession()
        await session.start()
        try await session.signUp(email: "zaina1z@cmich.edu", password: "Passw0rd!")

        #expect(session.state == .signedOut)
        #expect(await backend.recorded() == [
            .signUp(email: "zaina1z@cmich.edu"),
            .sendEmailVerification
        ])
    }

    @Test("a rejected sign-up leaves the session signed out")
    func failedSignUpKeepsSignedOut() async {
        let (session, _) = makeSession()
        await session.start()
        await #expect(throws: AuthError.disallowedDomain) {
            try await session.signUp(email: "someone@gmail.com", password: "Passw0rd!")
        }
        #expect(session.state == .signedOut)
    }

    @Test("signing out returns to signed out and tells the backend")
    func signOutClears() async throws {
        let (session, backend) = makeSession(restoring: .stub())
        await session.start()
        #expect(session.state == .signedIn(.stub()))

        await session.signOut()
        #expect(session.state == .signedOut)
        #expect(await backend.recorded().contains(.signOut))
    }
}
