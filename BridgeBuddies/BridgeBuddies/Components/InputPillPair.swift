import SwiftUI

/// Two fields sharing one pill card — Password / Confirm It on Profile Setup.
///
/// Grouped rather than stacked as two `InputPill`s because they are a single
/// validation unit, and the wireframe draws them inside one container for that
/// reason. Labels share a fixed column width so the two dividers line up; the
/// standalone `InputPill` sizes its label to content, which is correct there and
/// wrong here.
struct InputPillPair: View {
    let topLabel: String
    @Binding var topText: String
    let bottomLabel: String
    @Binding var bottomText: String
    var isSecure: Bool = true
    var helperText: String? = nil
    var labelWidth: CGFloat = 104

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            VStack(spacing: 16) {
                field(label: topLabel, text: $topText)
                field(label: bottomLabel, text: $bottomText)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.surfaceCardPure)
            .clipShape(RoundedRectangle(cornerRadius: Radius.card))
            .cardShadow()

            if let helperText {
                Text(helperText)
                    .font(.bodySM)
                    .foregroundColor(.textSecondary)
                    .padding(.horizontal, 8)
            }
        }
    }

    private func field(label: String, text: Binding<String>) -> some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.bodyMD)
                .foregroundColor(.textSecondary)
                .frame(width: labelWidth, alignment: .leading)

            Rectangle()
                .fill(Color.hairline)
                .frame(width: 1, height: 20)

            Group {
                if isSecure {
                    SecureField("", text: text)
                } else {
                    TextField("", text: text)
                }
            }
            .font(.bodyLG)
            .foregroundColor(.textPrimary)
        }
    }
}
