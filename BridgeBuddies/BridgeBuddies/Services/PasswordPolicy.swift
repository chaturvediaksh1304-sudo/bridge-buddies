import Foundation

/// The password rules Profile Setup already promises in its helper text
/// (wireframe 2.3): at least 8 characters, one uppercase, one lowercase, one
/// number, one special character.
///
/// Returns *every* failure rather than the first, so a form can list what's
/// still missing instead of revealing one rule at a time.
enum PasswordPolicy {
    static let minimumLength = 8

    enum Failure: Error, Equatable, Sendable {
        case tooShort(minimum: Int)
        case missingUppercase
        case missingLowercase
        case missingNumber
        case missingSpecial

        var message: String {
            switch self {
            case .tooShort(let minimum): return "Use at least \(minimum) characters."
            case .missingUppercase: return "Add an uppercase letter."
            case .missingLowercase: return "Add a lowercase letter."
            case .missingNumber: return "Add a number."
            case .missingSpecial: return "Add a special character."
            }
        }
    }

    static func failures(for password: String) -> [Failure] {
        var failures: [Failure] = []
        if password.count < minimumLength { failures.append(.tooShort(minimum: minimumLength)) }
        if !password.contains(where: \.isUppercase) { failures.append(.missingUppercase) }
        if !password.contains(where: \.isLowercase) { failures.append(.missingLowercase) }
        if !password.contains(where: \.isNumber) { failures.append(.missingNumber) }
        // Anything that isn't a letter or a digit counts, which keeps the rule
        // honest for non-Latin keyboards instead of hardcoding an ASCII set.
        if !password.contains(where: { !$0.isLetter && !$0.isNumber }) {
            failures.append(.missingSpecial)
        }
        return failures
    }

    static func isValid(_ password: String) -> Bool { failures(for: password).isEmpty }
}
