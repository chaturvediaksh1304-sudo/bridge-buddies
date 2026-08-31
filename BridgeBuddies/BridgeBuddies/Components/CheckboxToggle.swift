import SwiftUI

/// Square check control with a trailing label — "Remember Me" on Login.
///
/// Not a `Toggle`: SwiftUI ships switch and button styles, and the wireframes
/// draw a square box. The whole row is the hit target, and the checkmark springs
/// in with a little overshoot because ticking a box is a deliberate commit.
struct CheckboxToggle: View {
    @Binding var isOn: Bool
    let label: String
    var tint: Color = .textPrimary

    var body: some View {
        Button { isOn.toggle() } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.surfaceCardPure)
                        .frame(width: 30, height: 30)
                        .chipShadow()

                    if isOn {
                        Image(systemName: "checkmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.textPrimary)
                    }
                }

                Text(label)
                    .font(.bodyMD)
                    .foregroundColor(tint)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.96))
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isOn)
        .accessibilityAddTraits(isOn ? [.isButton, .isSelected] : .isButton)
    }
}
