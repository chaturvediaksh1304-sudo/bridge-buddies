import CryptoKit
import Foundation

/// Nonce handling for Sign in with Apple.
///
/// Apple signs the SHA256 of a nonce into the returned identity token; the
/// backend is handed the *raw* nonce and checks it matches. That round trip is
/// what stops a stolen token being replayed, so the random source has to be a
/// CSPRNG — hence `SecRandomCopyBytes` rather than `Int.random`.
enum SignInWithAppleNonce {
    /// 64 characters exactly, so mapping a random byte through it with `%`
    /// introduces no modulo bias (256 is a multiple of 64).
    private static let alphabet = Array(
        "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_"
    )

    static func randomNonce(length: Int = 32) -> String {
        precondition(length > 0, "Nonce length must be positive")

        var bytes = [UInt8](repeating: 0, count: length)
        let status = SecRandomCopyBytes(kSecRandomDefault, length, &bytes)
        precondition(status == errSecSuccess, "Unable to generate secure random bytes")

        return String(bytes.map { alphabet[Int($0) % alphabet.count] })
    }

    /// Lowercase hex SHA256 — the form Apple expects in the request's `nonce`.
    static func sha256(_ input: String) -> String {
        SHA256.hash(data: Data(input.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
    }
}
