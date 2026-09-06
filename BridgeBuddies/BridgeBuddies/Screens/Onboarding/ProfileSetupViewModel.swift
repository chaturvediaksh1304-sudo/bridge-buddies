import Observation
import SwiftUI

/// Drives Profile Setup: holds the draft, surfaces its rules as field-level
/// guidance, and creates the auth account.
///
/// Only email and password reach `AuthSession.signUp` — the rest of the draft
/// has nowhere to persist until Firestore lands in Phase 2, so it stays in
/// memory rather than being silently dropped.
@MainActor
@Observable
final class ProfileSetupViewModel {
    var draft = ProfileDraft()

    private(set) var isSubmitting = false
    private(set) var errorMessage: String?
    private(set) var didCreateAccount = false

    private let session: AuthSession
    private let validator: EmailDomainValidator

    init(session: AuthSession, school: School = .centralMichigan) {
        self.session = session
        self.validator = EmailDomainValidator(school: school)
    }

    private var issues: [ProfileDraft.Issue] { draft.issues(validatedBy: validator) }

    var canSubmit: Bool {
        !isSubmitting && !didCreateAccount && draft.hasAllRequiredFields && issues.isEmpty
    }

    // MARK: - Field guidance
    //
    // Rules are shown against the field they belong to rather than collected
    // into one summary, so the fix is always next to the problem. Each falls
    // back to its static helper text when there's nothing wrong.

    var emailHelper: String? {
        issues.first { $0 == .invalidEmail || $0 == .disallowedDomain }?.message
    }

    var passwordHelper: String {
        for issue in issues {
            if case .weakPassword = issue { return issue.message }
            if case .passwordsDontMatch = issue { return issue.message }
        }
        return Self.passwordRules
    }

    var bioHelper: String {
        for issue in issues {
            if case .bioTooLong = issue { return issue.message }
        }
        return Self.bioGuidance
    }

    private static let passwordRules = "Be at least 8 characters long; must include one uppercase letter; must include one lowercase letter; must include one number; must include one special character"
    private static let bioGuidance = "A short intro about you — interests, vibes, or what you're looking for\nCharacter limit: Max \(ProfileDraft.bioLimit) characters"

    // MARK: - Submit

    func submit() async {
        guard canSubmit else { return }

        errorMessage = nil
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            try await session.signUp(email: draft.normalizedEmail, password: draft.password)
            didCreateAccount = true
        } catch let error as AuthError {
            errorMessage = error.userFacingMessage
        } catch {
            errorMessage = AuthError.unknown(error.localizedDescription).userFacingMessage
        }
    }
}
