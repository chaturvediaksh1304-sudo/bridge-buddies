import Foundation

/// A signed-in identity, independent of whichever backend produced it.
///
/// Deliberately not a Firebase type: everything above `AuthBackend` works with
/// this, so the app compiles and its tests run without the Firebase SDK present.
struct AuthenticatedUser: Sendable, Equatable, Identifiable {
    let id: String
    let email: String
    let isEmailVerified: Bool
}
