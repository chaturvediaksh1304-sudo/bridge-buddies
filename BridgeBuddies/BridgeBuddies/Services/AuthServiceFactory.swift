import Foundation

/// Where the auth stack is assembled.
///
/// The single place that names a concrete backend, so switching from the
/// in-memory stand-in to Firebase is a one-line change here rather than an edit
/// in every screen.
extension AuthService {
    /// Runs against `InMemoryAuthBackend` — accounts live until the app quits.
    /// Real rules, no network. Replace with `.firebase(for:)` once the SDK is in
    /// the target and `GoogleService-Info.plist` is present.
    static func development(for school: School = .centralMichigan) -> AuthService {
        AuthService(backend: InMemoryAuthBackend(), validator: EmailDomainValidator(school: school))
    }

    #if canImport(FirebaseAuth)
    static func firebase(for school: School) -> AuthService {
        AuthService(backend: FirebaseAuthBackend(), validator: EmailDomainValidator(school: school))
    }
    #endif
}
