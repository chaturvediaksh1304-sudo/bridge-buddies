import SwiftUI

enum Spacing {
    static let screenH: CGFloat = 24
    static let stack: CGFloat = 16
    static let section: CGFloat = 32

    /// Bottom inset that clears the floating `BottomTabBar` — its pill, the
    /// raised active circle, and the 12pt the bar itself sits off the edge.
    /// Every tab screen uses this so the last row lands in the same place.
    static let tabBarClearance: CGFloat = 132
}

enum Radius {
    static let pill: CGFloat = 999
    /// Cards and sheets. Herae's corners are softer than a typical 28.
    static let card: CGFloat = 24
    /// Rows and chips nested inside a card.
    static let row: CGFloat = 16
}

extension View {
    /// Standard floating card shadow. Soft and low-contrast — the palette is
    /// pale enough that a heavy drop shadow reads as dirt rather than depth.
    func cardShadow() -> some View {
        self.shadow(color: .heraeInk.opacity(0.10), radius: 18, x: 0, y: 10)
    }

    /// Tighter shadow for small raised elements (chips, checkboxes, orbs).
    func chipShadow() -> some View {
        self.shadow(color: .heraeInk.opacity(0.08), radius: 8, x: 0, y: 3)
    }
}
