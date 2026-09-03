import Foundation

/// Every failure the auth layer can present, in the app's own vocabulary.
///
/// Backend adapters translate their SDK's errors into these, so screens never
/// see an `NSError` domain or a Firebase error code.
enum AuthError: Error, Equatable, Sendable {
    case invalidEmail
    case disallowedDomain
    case weakPassword([PasswordPolicy.Failure])
    case emailAlreadyInUse
    case wrongPassword
    case userNotFound
    case userDisabled
    case emailNotVerified
    case tooManyRequests
    case network
    case appleSignInCancelled
    case appleSignInFailed
    case unknown(String)
}

extension AuthError {
    /// Copy safe to show a user. Deliberately vague on the sign-in failures:
    /// distinguishing "no such account" from "wrong password" tells an attacker
    /// which addresses are registered.
    var userFacingMessage: String {
        switch self {
        case .invalidEmail:
            return "That doesn't look like a valid email address."
        case .disallowedDomain:
            return "Use your school email address to sign up."
        case .weakPassword(let failures):
            return failures.map(\.message).joined(separator: " ")
        case .emailAlreadyInUse:
            return "An account already exists for that address."
        case .wrongPassword, .userNotFound:
            return "That email and password don't match."
        case .userDisabled:
            return "This account has been disabled. Contact support."
        case .emailNotVerified:
            return "Check your inbox and confirm your email address first."
        case .tooManyRequests:
            return "Too many attempts. Try again in a few minutes."
        case .network:
            return "Can't reach the network. Check your connection."
        case .appleSignInCancelled:
            return "Sign in with Apple was cancelled."
        case .appleSignInFailed:
            return "Sign in with Apple didn't complete. Try again."
        case .unknown:
            return "Something went wrong. Try again."
        }
    }
}
