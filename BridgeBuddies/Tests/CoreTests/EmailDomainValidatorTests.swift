import Testing
@testable import BridgeBuddiesCore

@Suite("Email domain validation")
struct EmailDomainValidatorTests {
    let validator = EmailDomainValidator(allowedDomains: ["cmich.edu"])

    @Test("accepts a school address")
    func acceptsSchoolAddress() {
        #expect(validator.isAllowed("zaina1z@cmich.edu"))
    }

    @Test("is case-insensitive")
    func caseInsensitive() {
        #expect(validator.isAllowed("ZAINA1Z@CMICH.EDU"))
    }

    @Test("accepts a subdomain of the school domain")
    func acceptsSubdomain() {
        // Universities routinely issue mail.<school>.edu addresses, and nobody
        // outside the school can register one.
        #expect(validator.isAllowed("someone@mail.cmich.edu"))
    }

    @Test("rejects a lookalike domain that merely ends with the school name", arguments: [
        "attacker@cmich.edu.evil.com",
        "attacker@notcmich.edu",
        "attacker@evil-cmich.edu"
    ])
    func rejectsLookalikes(_ email: String) {
        #expect(!validator.isAllowed(email))
    }

    @Test("rejects a non-school address")
    func rejectsConsumerAddress() {
        #expect(!validator.isAllowed("someone@gmail.com"))
    }

    @Test("rejects malformed addresses", arguments: [
        "", "no-at-sign.edu", "@cmich.edu", "user@", "user@@cmich.edu",
        "user @cmich.edu", "user@cmich", "user@.cmich.edu", "us..er@cmich.edu"
    ])
    func rejectsMalformed(_ email: String) {
        #expect(!validator.isAllowed(email))
    }

    @Test("trims surrounding whitespace before judging")
    func trimsWhitespace() {
        #expect(validator.isAllowed("  zaina1z@cmich.edu  "))
    }
}
