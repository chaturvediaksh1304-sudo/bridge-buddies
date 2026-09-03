import Testing
@testable import BridgeBuddiesCore

/// The rules come from Profile Setup's own helper text (wireframe 2.3):
/// at least 8 characters, one uppercase, one lowercase, one number, one special.
@Suite("Password policy")
struct PasswordPolicyTests {
    @Test("accepts a password meeting every rule")
    func acceptsValid() {
        #expect(PasswordPolicy.failures(for: "Passw0rd!").isEmpty)
    }

    @Test("reports too-short")
    func reportsShort() {
        #expect(PasswordPolicy.failures(for: "Pw1!").contains(.tooShort(minimum: 8)))
    }

    @Test("reports each missing character class", arguments: [
        ("passw0rd!", PasswordPolicy.Failure.missingUppercase),
        ("PASSW0RD!", PasswordPolicy.Failure.missingLowercase),
        ("Password!", PasswordPolicy.Failure.missingNumber),
        ("Passw0rdd", PasswordPolicy.Failure.missingSpecial)
    ])
    func reportsMissingClass(_ password: String, _ expected: PasswordPolicy.Failure) {
        #expect(PasswordPolicy.failures(for: password).contains(expected))
    }

    @Test("reports every failure at once so the form can list them")
    func reportsAllFailures() {
        // Short, no uppercase, no number, no special — four at once.
        let failures = PasswordPolicy.failures(for: "abc")
        #expect(failures.count == 4)
    }
}
