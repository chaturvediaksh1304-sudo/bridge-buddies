import Testing
@testable import BridgeBuddies

@Suite("Sign in with Apple nonce")
struct SignInWithAppleNonceTests {
    @Test("generates a nonce of the requested length")
    func generatesRequestedLength() {
        #expect(SignInWithAppleNonce.randomNonce(length: 32).count == 32)
    }

    @Test("generates a different nonce each time")
    func generatesUniqueNonces() {
        let nonces = Set((0..<50).map { _ in SignInWithAppleNonce.randomNonce() })
        #expect(nonces.count == 50)
    }

    @Test("uses only URL-safe characters")
    func usesSafeAlphabet() {
        let allowed = Set("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._")
        #expect(SignInWithAppleNonce.randomNonce(length: 200).allSatisfy(allowed.contains))
    }

    @Test("hashes to lowercase hex SHA256")
    func hashesToHex() {
        let hash = SignInWithAppleNonce.sha256("nonce")
        #expect(hash.count == 64)
        #expect(hash.allSatisfy { $0.isHexDigit && !$0.isUppercase })
    }

    @Test("hashing is stable for a known input")
    func hashIsStable() {
        // Independently verifiable: echo -n "abc" | shasum -a 256
        #expect(SignInWithAppleNonce.sha256("abc")
            == "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")
    }
}
