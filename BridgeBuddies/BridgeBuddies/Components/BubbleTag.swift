import SwiftUI

/// Lays its children out left-to-right, wrapping onto a new line when the next
/// child won't fit.
///
/// SwiftUI ships no wrapping stack, and Identity Bubbles needs one because the
/// tag widths are content-driven — a `LazyVGrid` would force a column rhythm the
/// wireframe's ragged-right bubble field doesn't have.
struct FlowLayout: Layout {
    var spacing: CGFloat = 10
    var lineSpacing: CGFloat = 12

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        let laidOut = rows(maxWidth: maxWidth, subviews: subviews)
        let height = laidOut.reduce(0) { $0 + $1.height }
            + lineSpacing * CGFloat(max(laidOut.count - 1, 0))
        let width = maxWidth.isFinite ? maxWidth : (laidOut.map(\.width).max() ?? 0)
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for row in rows(maxWidth: bounds.width, subviews: subviews) {
            var x = bounds.minX
            for index in row.indices {
                let size = subviews[index].sizeThatFits(.unspecified)
                subviews[index].place(
                    at: CGPoint(x: x, y: y + (row.height - size.height) / 2),
                    proposal: ProposedViewSize(size)
                )
                x += size.width + spacing
            }
            y += row.height + lineSpacing
        }
    }

    private struct Row {
        var indices: [Int] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }

    private func rows(maxWidth: CGFloat, subviews: Subviews) -> [Row] {
        var result: [Row] = []
        var current = Row()

        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let projected = current.indices.isEmpty
                ? size.width
                : current.width + spacing + size.width

            if projected > maxWidth && !current.indices.isEmpty {
                result.append(current)
                current = Row(indices: [index], width: size.width, height: size.height)
            } else {
                current.indices.append(index)
                current.width = projected
                current.height = max(current.height, size.height)
            }
        }

        if !current.indices.isEmpty { result.append(current) }
        return result
    }
}

/// A selectable identity pill.
///
/// Selection is carried by weight, colour and elevation together rather than by
/// a colour fill alone — the bubble field is dense, and four saturated blocks
/// would fight the maroon ground. The commit spring keeps a little overshoot
/// (damping 0.8) because tapping a bubble is a deliberate physical act; the
/// press itself stays critically damped via `PressableStyle`.
struct BubbleTag: View {
    let text: String
    var isSelected: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .textPrimary : .textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? Color.surfaceSolid : Color.surfaceCardAlt)
                .clipShape(Capsule())
                .shadow(color: .heraeInk.opacity(isSelected ? 0.16 : 0.06),
                        radius: isSelected ? 10 : 5,
                        x: 0,
                        y: isSelected ? 5 : 2)
        }
        .buttonStyle(PressableStyle(scale: 0.94))
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isSelected)
    }
}
