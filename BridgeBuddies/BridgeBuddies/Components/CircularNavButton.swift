import SwiftUI

/// White circular back/forward button for linear onboarding steps. §2.4.
struct CircularNavButton: View {
    enum Direction { case back, forward }
    let direction: Direction
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: direction == .back ? "arrow.left" : "arrow.right")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.textPrimary)
                .frame(width: 52, height: 52)
                .background(Color.surfaceCardPure)
                .clipShape(Circle())
                .cardShadow()
        }
        .opacity(isEnabled ? 1.0 : 0.4)
        .disabled(!isEnabled)
    }
}
