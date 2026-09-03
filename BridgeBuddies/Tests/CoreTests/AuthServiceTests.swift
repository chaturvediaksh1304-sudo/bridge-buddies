import Testing
@testable import BridgeBuddies

/// Records what it was asked to do and returns whatever the test sets up, so
/// every AuthService rule can be checked without a network or a Firebase project.
actor FakeAuthBackend: AuthBackend {
    enum Call: Equatable {
        case signUp(email: String)
        case signIn(email: String)
        case signInWithApple
        case sendEmailVerification
        case sendPasswordReset(email: String)
        case signOut
    }

    private(set) var calls: [Call] = []
    private var result: Result<AuthenticatedUser, Error>

    init(returning user: AuthenticatedUser = .stub()) {
        self.result = .success(user)
    }

    func setFailure(_ error: Error) { result = .failure(error) }
    func recorded() -> [Call] { calls }

    func signUp(email: String, password: String) async throws -> AuthenticatedUser {
        calls.append(.signUp(email: email))
        return try result.get()
    }

    func signIn(email: String, password: String) async throws -> AuthenticatedUser {
        calls.append(.signIn(email: email))
        return try result.get()
    }

    func signInWithApple(idToken: String, rawNonce: String) async throws -> AuthenticatedUser {
        calls.append(.signInWithApple)
        return try result.get()
    }

    func sendEmailVerification() async throws { calls.append(.sendEmailVerification) }
    func sendPasswordReset(email: String) async throws { calls.append(.sendPasswordReset(email: email)) }
    func signOut() async throws { calls.append(.signOut) }
}

extension AuthenticatedUser {
    static func stub(isEmailVerified: Bool = true) -> AuthenticatedUser {
        AuthenticatedUser(id: "uid-1", email: "zaina1z@cmich.edu", isEmailVerified: isEmailVerified)
    }
}

@Suite("Auth service")
struct AuthServiceTests {
    private func makeService(
        backend: FakeAuthBackend = FakeAuthBackend()
    ) -> (AuthService, FakeAuthBackend) {
        (AuthService(backend: backend, validator: EmailDomainValidator(allowedDomains: ["cmich.edu"])), backend)
    }

    @Test("refuses a non-school address without touching the backend")
    func rejectsDisallowedDomain() async {
        let (service, backend) = makeService()
        await #expect(throws: AuthError.disallowedDomain) {
            try await service.signUp(email: "someone@gmail.com", password: "Passw0rd!")
        }
        #expect(await backend.recorded().isEmpty)
    }

    @Test("refuses a weak password without touching the backend")
    func rejectsWeakPassword() async {
        let (service, backend) = makeService()
        await #expect(throws: AuthError.self) {
            try await service.signUp(email: "zaina1z@cmich.edu", password: "abc")
        }
        #expect(await backend.recorded().isEmpty)
    }

    @Test("sends a verification email on successful sign-up")
    func sendsVerificationOnSignUp() async throws {
        let (service, backend) = makeService()
        _ = try await service.signUp(email: "zaina1z@cmich.edu", password: "Passw0rd!")
        #expect(await backend.recorded() == [
            .signUp(email: "zaina1z@cmich.edu"),
            .sendEmailVerification
        ])
    }

    @Test("normalises the address before handing it to the backend")
    func normalisesEmail() async throws {
        let (service, backend) = makeService()
        _ = try await service.signUp(email: "  ZAINA1Z@CMICH.EDU ", password: "Passw0rd!")
        #expect(await backend.recorded().first == .signUp(email: "zaina1z@cmich.edu"))
    }

    @Test("blocks sign-in until the address is verified")
    func blocksUnverifiedSignIn() async {
        let backend = FakeAuthBackend(returning: .stub(isEmailVerified: false))
        let (service, _) = makeService(backend: backend)
        await #expect(throws: AuthError.emailNotVerified) {
            try await service.signIn(email: "zaina1z@cmich.edu", password: "Passw0rd!")
        }
    }

    @Test("returns the user once verified")
    func allowsVerifiedSignIn() async throws {
        let (service, _) = makeService()
        let user = try await service.signIn(email: "zaina1z@cmich.edu", password: "Passw0rd!")
        #expect(user.id == "uid-1")
    }

    @Test("does not apply the domain rule to Apple Sign-In")
    func appleSignInSkipsDomainRule() async throws {
        // Apple's private relay addresses are @privaterelay.appleid.com, so a
        // school-domain rule would reject every relay user. Verification for
        // these has to happen another way.
        let backend = FakeAuthBackend(returning: AuthenticatedUser(
            id: "uid-2", email: "abc@privaterelay.appleid.com", isEmailVerified: true))
        let (service, _) = makeService(backend: backend)
        let user = try await service.signInWithApple(idToken: "token", rawNonce: "nonce")
        #expect(user.id == "uid-2")
    }

    @Test("surfaces a backend failure as an AuthError")
    func mapsBackendFailure() async {
        let backend = FakeAuthBackend()
        await backend.setFailure(AuthError.emailAlreadyInUse)
        let (service, _) = makeService(backend: backend)
        await #expect(throws: AuthError.emailAlreadyInUse) {
            try await service.signUp(email: "zaina1z@cmich.edu", password: "Passw0rd!")
        }
    }

    @Test("password reset still enforces the school domain")
    func resetEnforcesDomain() async {
        let (service, backend) = makeService()
        await #expect(throws: AuthError.disallowedDomain) {
            try await service.sendPasswordReset(email: "someone@gmail.com")
        }
        #expect(await backend.recorded().isEmpty)
    }
}
