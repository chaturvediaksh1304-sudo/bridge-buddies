#if canImport(FirebaseAuth)
import FirebaseAuth
import Foundation

/// `AuthBackend` implemented against Firebase.
///
/// Compiles to nothing until the FirebaseAuth SDK is added to the target, which
/// is why the rest of the auth layer builds and tests without it. Its only jobs
/// are performing the call and translating Firebase's `NSError` codes into
/// `AuthError` — no policy lives here.
///
/// ⚠️ Unverified: this file has never been compiled, because the SDK isn't in
/// the project yet. Expect to fix the error-code API against whichever
/// Firebase major version you install.
actor FirebaseAuthBackend: AuthBackend {
    private var auth: Auth { Auth.auth() }

    func signUp(email: String, password: String) async throws -> AuthenticatedUser {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            return Self.user(from: result.user)
        } catch {
            throw Self.mapped(error)
        }
    }

    func signIn(email: String, password: String) async throws -> AuthenticatedUser {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            // The cached flag goes stale the moment someone clicks the link in
            // their inbox, so refresh before reporting verification status.
            try? await result.user.reload()
            return Self.user(from: result.user)
        } catch {
            throw Self.mapped(error)
        }
    }

    func signInWithApple(idToken: String, rawNonce: String) async throws -> AuthenticatedUser {
        do {
            let credential = OAuthProvider.appleCredential(
                withIDToken: idToken, rawNonce: rawNonce, fullName: nil
            )
            let result = try await auth.signIn(with: credential)
            return Self.user(from: result.user)
        } catch {
            throw Self.mapped(error)
        }
    }

    func sendEmailVerification() async throws {
        guard let user = auth.currentUser else { throw AuthError.userNotFound }
        do { try await user.sendEmailVerification() } catch { throw Self.mapped(error) }
    }

    func sendPasswordReset(email: String) async throws {
        do { try await auth.sendPasswordReset(withEmail: email) } catch { throw Self.mapped(error) }
    }

    func signOut() async throws {
        do { try auth.signOut() } catch { throw Self.mapped(error) }
    }

    private static func user(from user: User) -> AuthenticatedUser {
        AuthenticatedUser(
            id: user.uid,
            email: user.email ?? "",
            isEmailVerified: user.isEmailVerified
        )
    }

    private static func mapped(_ error: Error) -> AuthError {
        if let error = error as? AuthError { return error }

        let nsError = error as NSError
        switch AuthErrorCode(rawValue: nsError.code) {
        case .invalidEmail: return .invalidEmail
        case .weakPassword: return .weakPassword([.tooShort(minimum: PasswordPolicy.minimumLength)])
        case .emailAlreadyInUse: return .emailAlreadyInUse
        case .wrongPassword, .invalidCredential: return .wrongPassword
        case .userNotFound: return .userNotFound
        case .userDisabled: return .userDisabled
        case .tooManyRequests: return .tooManyRequests
        case .networkError: return .network
        default: return .unknown(nsError.localizedDescription)
        }
    }
}
#endif
