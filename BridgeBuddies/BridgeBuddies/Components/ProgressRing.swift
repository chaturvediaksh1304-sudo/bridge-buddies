import SwiftUI

/// Circular segmented ring chart with a centered metric. §2.15.
/// e.g. segments = [("Friends", 18, .heraeSage), ("Mentors", 2, .heraeCream), ("Mentees", 7, .heraeOlive)]
struct ProgressRing: View {
    struct Segment {
        let label: String
        let value: Int
        let color: Color
    }

    let segments: [Segment]
    let centerValue: String
    let centerLabel: String

    private var total: Int { max(segments.reduce(0) { $0 + $1.value }, 1) }

    var body: some View {
        ZStack {
            ForEach(Array(segments.enumerated()), id: \.offset) { index, segment in
                let startFraction = Double(segments[..<index].reduce(0) { $0 + $1.value }) / Double(total)
                let endFraction = startFraction + Double(segment.value) / Double(total)

                Circle()
                    .trim(from: startFraction, to: endFraction)
                    .stroke(segment.color, style: StrokeStyle(lineWidth: 22, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }

            VStack(spacing: 4) {
                Text(centerValue)
                    .font(.displaySM)
                    .foregroundColor(.textPrimary)
                Text(centerLabel)
                    .font(.bodyMD)
                    .foregroundColor(.textSecondary)
            }
        }
        .frame(width: 220, height: 220)
        .padding(20)
    }
}
