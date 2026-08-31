import SwiftUI

/// A single bare text line inside a `ListCard` — the school index on School
/// Select and the resource index on Campus Resources.
///
/// No dividers and no chevron on purpose: both wireframes keep these lists as a
/// quiet block of text, so the row's only affordances are its press state and,
/// where selectable, a weight-and-colour shift plus a checkmark. Adding rules
/// between rows would turn a calm index into a settings table.
struct PlainListRow: View {
    let title: String
    var isSelected: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(title)
                    .font(.bodyMD)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .textPrimary : .textSecondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.heraeOlive)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 7)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.99))
        .animation(.spring(response: 0.35, dampingFraction: 1.0), value: isSelected)
    }
}

/// Icon disc + label + chevron — the settings block on Profile.
///
/// Designed to sit inside a `ListCard`, which already supplies the surface and
/// padding, so this row carries no background of its own.
struct SettingsMenuRow: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 18) {
                ZStack {
                    Circle().fill(Color.heraeSage)
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.textPrimary)
                }
                .frame(width: 40, height: 40)

                Text(title)
                    .font(.bodyMD)
                    .foregroundColor(.textPrimary)

                Spacer(minLength: 12)

                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.textPrimary)
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.985))
    }
}
