import SwiftUI

/// Full-width pill CTA. `.dark` is the olive primary action, `.light` the
/// frosted secondary. §2.5.
struct PrimaryButton: View {
    enum Style { case dark, light }

    let title: String
    var style: Style = .dark
    /// Defaults to the sans body step. Login overrides it with the display
    /// serif, which the wireframe sets to match its title.
    var font: Font = .bodyLG
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(font)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .foregroundColor(style == .dark ? .textInverse : .textPrimary)
                .background(
                    Group {
                        if style == .dark {
                            LinearGradient.action
                        } else {
                            Color.surfaceCardPure
                        }
                    }
                )
                .clipShape(Capsule())
                .cardShadow()
        }
    }
}
