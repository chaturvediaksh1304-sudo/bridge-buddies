import SwiftUI

/// Compact card for dashboard modules. §2.14.
struct ModuleCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            content
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: Radius.card))
        .cardShadow()
    }
}

/// Three equal-width stats in a row. §2.16.
///
/// `.card` (default) gives each stat its own tinted tile, label above value —
/// the dashboard treatment on Home. `.plain` drops the tiles and flips the
/// order to value-over-label, centred, for stats that already sit inside a
/// host card (the Profile header) where a second surface would double up.
struct StatTrioRow: View {
    enum Style { case card, plain }

    struct Stat {
        let label: String
        let value: String
    }
    let stats: [Stat]  // expects exactly 3
    var style: Style = .card

    var body: some View {
        HStack(spacing: style == .card ? 12 : 0) {
            ForEach(Array(stats.enumerated()), id: \.offset) { _, stat in
                switch style {
                case .card:
                    VStack(alignment: .leading, spacing: 4) {
                        Text(stat.label)
                            .font(.bodySM)
                            .foregroundColor(.textSecondary)
                        Text(stat.value)
                            .font(.displaySM)
                            .foregroundColor(.textPrimary)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.surfaceCard)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                case .plain:
                    VStack(spacing: 2) {
                        Text(stat.value)
                            .font(.displayFont(size: 34))
                            .tracking(-0.5)
                            .foregroundColor(.textPrimary)
                        Text(stat.label)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

/// Segmented gradient bar, e.g. compatibility strength. §2.17.
struct RangeGradientBar: View {
    let value: Double // 0...1
    var leftLabel: String = "Low"
    var rightLabel: String = "High"
    var segmentCount: Int = 18

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 3) {
                ForEach(0..<segmentCount, id: \.self) { i in
                    let filled = Double(i) / Double(segmentCount) < value
                    RoundedRectangle(cornerRadius: 2)
                        .fill(filled ? Color.heraeOlive : Color.heraeCream.opacity(0.5))
                        .frame(height: 20)
                }
            }
            HStack {
                Text(leftLabel).font(.bodySM).foregroundColor(.textSecondary)
                Spacer()
                Text(rightLabel).font(.bodySM).foregroundColor(.textSecondary)
            }
        }
    }
}

/// Status-dot list row with primary/secondary text and optional chevron. §2.18.
struct ExpandableDataRow: View {
    let title: String
    let subtitle: String
    var dotColor: Color = .statusAvailable
    var showChevron: Bool = true

    var body: some View {
        HStack(spacing: 12) {
            Circle().fill(dotColor).frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.bodyLG).foregroundColor(.textPrimary)
                Text(subtitle).font(.bodySM).foregroundColor(.textSecondary)
            }
            Spacer()
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(.vertical, 10)
    }
}

/// Segmented filter pill group. §2.19.
struct FilterPillGroup: View {
    let options: [String]
    @Binding var selected: String

    var body: some View {
        HStack(spacing: 10) {
            ForEach(options, id: \.self) { option in
                Text(option)
                    .font(.bodyMD)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(selected == option ? Color.heraeOlive : Color.clear)
                    .foregroundColor(selected == option ? .white : .textSecondary)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(Color.textSecondary.opacity(0.3), lineWidth: selected == option ? 0 : 1)
                    )
                    .onTapGesture { selected = option }
            }
        }
    }
}

/// Icon + two-line label + chevron, fully tappable card. §2.20.
struct DetailCardWithIconCTA: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(Color.heraeOlive.opacity(0.2))
                    Image(systemName: icon).foregroundColor(.heraeOlive)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.bodyLG).foregroundColor(.textPrimary)
                    Text(subtitle).font(.bodySM).foregroundColor(.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.textSecondary)
            }
            .padding(16)
            .background(Color.surfaceCard)
            .clipShape(RoundedRectangle(cornerRadius: Radius.card))
        }
        .buttonStyle(.plain)
    }
}
