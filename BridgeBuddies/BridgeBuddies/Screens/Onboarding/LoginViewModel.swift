import Observation
import SwiftUI

/// Holds Login's form state and talks to `AuthService`.
///
/// Every failure becomes `errorMessage`; the view never sees an `AuthError` or
/// decides what an error means. `isSubmitting` gates the CTA so a double-tap
/// can't fire two sign-in attempts.
@MainActor
@Observable
final class LoginViewModel {
    var email = ""
    var password = ""
    var rememberMe = false

    private(set) var isSubmitting = false
    private(set) var errorMessage: String?
    private(set) var signedInUser: AuthenticatedUser?

    private let auth: AuthService

    init(auth: AuthService = .development()) {
        self.auth = auth
    }

    var canSubmit: Bool {
        !isSubmitting
            && !email.trimmingCharacters(in: .whitespaces).isEmpty
            && !password.isEmpty
    }

    func logIn() async {
        guard canSubmit else { return }
        await run { self.signedInUser = try await self.auth.signIn(email: self.email, password: self.password) }
    }

    func sendPasswordReset() async {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Enter your email address first."
            return
        }
        await run { try await self.auth.sendPasswordReset(email: self.email) }
    }

    private func run(_ operation: @escaping () async throws -> Void) async {
        errorMessage = nil
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            try await operation()
        } catch let error as AuthError {
            errorMessage = error.userFacingMessage
        } catch {
            errorMessage = AuthError.unknown(error.localizedDescription).userFacingMessage
        }
    }
}
