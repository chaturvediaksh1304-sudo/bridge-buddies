import Testing
@testable import BridgeBuddies

@Suite("Profile draft")
struct ProfileDraftTests {
    let validator = EmailDomainValidator(allowedDomains: ["cmich.edu"])

    /// Every required field filled with something valid.
    private func complete() -> ProfileDraft {
        var draft = ProfileDraft()
        draft.firstName = "Zainab"
        draft.lastName = "Khan"
        draft.userName = "zainab"
        draft.email = "zaina1z@cmich.edu"
        draft.phone = "+1 989 555 0100"
        draft.password = "Passw0rd!"
        draft.confirmPassword = "Passw0rd!"
        draft.dateOfBirth = "03/07/2003"
        draft.bio = "New here, looking for people to study with."
        return draft
    }

    @Test("a complete draft has nothing to complain about")
    func completeDraftIsValid() {
        let draft = complete()
        #expect(draft.hasAllRequiredFields)
        #expect(draft.issues(validatedBy: validator).isEmpty)
    }

    @Test("optional fields really are optional")
    func optionalFieldsAreOptional() {
        // Location, Major and Standing carry no asterisk in the wireframe.
        var draft = complete()
        draft.location = ""
        draft.major = ""
        draft.standing = ""
        #expect(draft.hasAllRequiredFields)
    }

    @Test("a missing starred field blocks submission")
    func missingRequiredFieldBlocks() {
        // Looped rather than parameterised: key paths aren't Sendable, which
        // `arguments:` requires.
        let required: [(String, WritableKeyPath<ProfileDraft, String>)] = [
            ("firstName", \.firstName), ("lastName", \.lastName), ("userName", \.userName),
            ("email", \.email), ("phone", \.phone), ("password", \.password),
            ("confirmPassword", \.confirmPassword), ("dateOfBirth", \.dateOfBirth),
            ("bio", \.bio)
        ]

        for (name, field) in required {
            var draft = complete()
            draft[keyPath: field] = "   "
            #expect(!draft.hasAllRequiredFields, "blank \(name) should block submission")
        }
    }

    @Test("catches passwords that don't match")
    func catchesMismatchedPasswords() {
        var draft = complete()
        draft.confirmPassword = "Passw0rd?"
        #expect(draft.issues(validatedBy: validator).contains(.passwordsDontMatch))
    }

    @Test("catches a password that fails the policy")
    func catchesWeakPassword() {
        var draft = complete()
        draft.password = "abc"
        draft.confirmPassword = "abc"
        let issues = draft.issues(validatedBy: validator)
        #expect(issues.contains { if case .weakPassword = $0 { true } else { false } })
    }

    @Test("does not report a mismatch when the password is already invalid")
    func mismatchNotStackedOnWeakPassword() {
        // Two complaints about the same field at once reads as noise; the policy
        // failure is the one worth fixing first.
        var draft = complete()
        draft.password = "abc"
        draft.confirmPassword = "def"
        #expect(!draft.issues(validatedBy: validator).contains(.passwordsDontMatch))
    }

    @Test("catches a non-school address")
    func catchesDisallowedDomain() {
        var draft = complete()
        draft.email = "someone@gmail.com"
        #expect(draft.issues(validatedBy: validator).contains(.disallowedDomain))
    }

    @Test("catches a malformed address")
    func catchesMalformedEmail() {
        var draft = complete()
        draft.email = "not-an-address"
        #expect(draft.issues(validatedBy: validator).contains(.invalidEmail))
    }

    @Test("catches an over-long bio")
    func catchesLongBio() {
        var draft = complete()
        draft.bio = String(repeating: "a", count: ProfileDraft.bioLimit + 1)
        #expect(draft.issues(validatedBy: validator).contains(.bioTooLong(limit: ProfileDraft.bioLimit)))
    }

    @Test("normalises the address it hands to sign-up")
    func normalisesEmail() {
        var draft = complete()
        draft.email = "  ZAINA1Z@CMICH.EDU  "
        #expect(draft.normalizedEmail == "zaina1z@cmich.edu")
    }
}
