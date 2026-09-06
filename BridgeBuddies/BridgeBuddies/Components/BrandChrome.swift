import SwiftUI

/// The Bridge Buddies serif wordmark lockup.
///
/// Appears on Splash, School Select, the Login footer and the Profile footer —
/// same letterforms every time, only size and tint change. Tracking is derived
/// from the size rather than fixed, because a display serif set large reads too
/// loose at the tracking that suits it small (apple-design §15).
struct Wordmark: View {
    var size: CGFloat = 28
    var tint: Color = .textPrimary
    /// The trailing © glyph on the full lockup (wireframes 1, 2.1, 6.1).
    var showsCopyright: Bool = true

    var body: some View {
        HStack(alignment: .top, spacing: 3) {
            Text("Bridge Buddies")
                .font(.displayFont(size: size))
                .tracking(size * -0.02)
            if showsCopyright {
                Text("©")
                    .font(.system(size: max(size * 0.2, 7), weight: .medium))
                    .padding(.top, size * 0.32)
            }
        }
        .foregroundColor(tint)
    }
}

/// A centred label flanked by hairline rules.
///
/// Two uses, deliberately the same component: the gold university eyebrow on
/// Campus Resources and the "Tap to select" separator on Identity Bubbles. Both
/// are doing the same job — quietly splitting a screen into two regions without
/// the weight of a heading.
struct RuledLabel: View {
    let text: String
    var tint: Color = .textSecondary
    /// Defaults to `tint`; pass separately when the rule should be quieter than
    /// the label (or the other way round).
    var ruleTint: Color? = nil

    var body: some View {
        HStack(spacing: 14) {
            rule
            Text(text)
                .font(.bodyMD)
                .foregroundColor(tint)
                .fixedSize(horizontal: true, vertical: false)
            rule
        }
    }

    private var rule: some View {
        Rectangle()
            .fill(ruleTint ?? tint)
            .frame(height: 1)
            .frame(maxWidth: .infinity)
    }
}

/// Inline legal links, evenly distributed — the footer on Profile Setup and
/// Profile. Kept as one component so the two screens can't drift apart on
/// spacing or type.
struct LegalLinksRow: View {
    let links: [String]
    var tint: Color = .textPrimary
    /// Footer type, not body type. Three links at `.bodyMD` overflow a 393pt
    /// screen, so the default is the smaller step the wireframes actually draw.
    var font: Font = .bodySM
    var onTap: (String) -> Void = { _ in }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(links.enumerated()), id: \.offset) { index, link in
                if index > 0 { Spacer(minLength: 14) }
                Button { onTap(link) } label: {
                    Text(link)
                        .font(font)
                        .foregroundColor(tint)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .layoutPriority(1)
                }
                .buttonStyle(PressableStyle(scale: 0.95))
            }
        }
    }
}
