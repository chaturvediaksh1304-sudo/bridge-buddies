import SwiftUI

/// Presence picker on Chat List.
///
/// Deliberately not a `FilterPillGroup`: that component paints every option with
/// one shared accent, and here each option's colour *is* its meaning. Selected
/// reads as a filled chip; unselected keeps the same hue but drops to an outline,
/// so the palette stays legible without four solid blocks competing for the eye.
struct StatusSelector: View {
    @Binding var selection: PresenceStatus
    /// Wireframe order, left to right. `PresenceStatus` isn't `CaseIterable`,
    /// and its declaration order isn't the presentation order, so the sequence
    /// is stated here rather than inferred.
    var options: [PresenceStatus] = [.none, .away, .busy, .available]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(Array(options.enumerated()), id: \.offset) { _, status in
                let isSelected = status == selection
                Button { selection = status } label: {
                    Text(status.label)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(isSelected ? .white : status.color)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 7)
                        .background(isSelected ? status.color : Color.clear)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().strokeBorder(status.color,
                                                   lineWidth: isSelected ? 0 : 1.5)
                        )
                }
                .buttonStyle(PressableStyle(scale: 0.93))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selection)
    }
}
