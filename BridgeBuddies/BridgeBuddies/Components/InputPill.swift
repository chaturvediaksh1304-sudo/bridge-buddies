import SwiftUI

/// White rounded field. Two layouts, one component — they share the surface,
/// the shadow, the secure/multiline handling and the helper text, and only
/// differ in where the label sits. §2.1 in UI_SPEC.
struct InputPill: View {
    /// How the label relates to its value.
    ///
    /// `.inline` — label, hairline divider and value on one row inside a full
    /// pill. The Profile Setup / Edit Profile treatment, where a dozen fields
    /// need to stay compact.
    ///
    /// `.stacked` — label above the value inside a rounded card. The Login
    /// treatment: two fields carrying the whole screen, so they can afford the
    /// height and the value gets a line to itself.
    enum Layout { case inline, stacked }

    let label: String
    @Binding var text: String
    var layout: Layout = .inline
    var isSecure: Bool = false
    var isMultiline: Bool = false
    var helperText: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Group {
                switch layout {
                case .inline: inlineBody
                case .stacked: stackedBody
                }
            }
            .background(Color.surfaceCardPure)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .cardShadow()

            if let helperText {
                Text(helperText)
                    .font(.bodySM)
                    .foregroundColor(.textSecondary)
                    .padding(.horizontal, 8)
            }
        }
    }

    private var cornerRadius: CGFloat {
        switch layout {
        case .stacked: return Radius.card
        case .inline: return isMultiline ? Radius.card : Radius.pill
        }
    }

    private var inlineBody: some View {
        HStack(alignment: isMultiline ? .top : .center, spacing: 12) {
            Text(label)
                .font(.bodyMD)
                .foregroundColor(.textSecondary)
                .fixedSize(horizontal: true, vertical: false)

            Rectangle()
                .fill(Color.hairline)
                .frame(width: 1, height: isMultiline ? 60 : 20)

            field
        }
        .padding(.horizontal, 20)
        .padding(.vertical, isMultiline ? 16 : 14)
    }

    private var stackedBody: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.bodyMD)
                .foregroundColor(.textSecondary)

            field
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var field: some View {
        Group {
            if isMultiline {
                TextField("", text: $text, axis: .vertical)
                    .lineLimit(3...6)
            } else if isSecure {
                SecureField("", text: $text)
            } else {
                TextField("", text: $text)
            }
        }
        .font(.bodyLG)
        .foregroundColor(.textPrimary)
    }
}
