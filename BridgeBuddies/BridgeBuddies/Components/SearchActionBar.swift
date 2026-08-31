import SwiftUI

/// White pill search/action bar. §2.2 in UI_SPEC.
struct SearchActionBar: View {
    @Binding var text: String
    var placeholder: String = "Search"
    var trailingIcon: String = "slider.horizontal.3"
    var onTrailingTap: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(Color.surfaceCardAlt)
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.textSecondary)
                    .font(.system(size: 14))
            }
            .frame(width: 32, height: 32)

            TextField(placeholder, text: $text)
                .font(.bodyMD)
                .foregroundColor(.textPrimary)

            Button(action: { onTrailingTap?() }) {
                Image(systemName: trailingIcon)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.surfaceCardPure)
        .clipShape(Capsule())
        .cardShadow()
    }
}
