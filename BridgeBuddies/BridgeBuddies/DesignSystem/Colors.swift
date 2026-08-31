import SwiftUI

// MARK: - Bridge Buddies Color Tokens
//
// Herae-derived palette. Five source swatches carry the entire system — there
// is no second accent and no brand color beyond them. The only hues outside the
// palette are the four semantic status colors, which encode meaning (available,
// busy, off campus, none) rather than style, and are retuned to sit with the
// palette rather than shout over it.
//
// Do not hardcode hex values in screens or components — use these.

extension Color {
    // MARK: Palette — the five source swatches

    static let heraeCream = Color(hex: "F4E0AC")
    static let heraeSage = Color(hex: "D6DDC6")
    static let heraeOlive = Color(hex: "8E9E6E")
    static let heraeInk = Color(hex: "10120C")

    // MARK: Surfaces
    //
    // Translucent by design. Cards sit *on* the canvas gradient and let it read
    // through, which is what gives the layered depth; an opaque white card
    // would punch a hole in the ground (apple-design §12). Never stack a
    // lighter translucent surface on another — `surfaceCardAlt` is the nested
    // layer and is always the quieter one.

    /// Primary frosted card — list cards, module cards, input fields.
    static let surfaceCardPure = Color.white.opacity(0.58)
    /// Slightly quieter card, for surfaces that sit next to a primary one.
    static let surfaceCard = Color.white.opacity(0.44)
    /// Nested layer: rows and chips *inside* an already-raised card.
    static let surfaceCardAlt = Color.white.opacity(0.28)
    /// Fully opaque, for the few places a surface must not tint.
    static let surfaceSolid = Color.white

    // MARK: Text
    //
    // The canvas is light everywhere now, so ink is the default and white is
    // the exception — used only on olive fills.

    static let textPrimary = heraeInk
    static let textSecondary = Color(hex: "10120C").opacity(0.52)
    /// On an olive fill (primary buttons, active tab, filled status pills).
    static let textInverse = Color.white
    static let textInverseMuted = Color.white.opacity(0.78)

    // MARK: Status
    //
    // The one sanctioned departure from the palette: these carry meaning, so
    // they have to stay distinguishable. Desaturated to sit with the sage and
    // cream instead of competing with them.

    static let statusAvailable = Color(hex: "7A9A5C")
    static let statusBusy = Color(hex: "C05F4E")
    static let statusAway = Color(hex: "D9A441")
    static let statusNone = Color(hex: "A9AE9C")

    // MARK: Lines

    /// Hairline rules and field dividers.
    static let hairline = Color(hex: "10120C").opacity(0.14)

    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

extension LinearGradient {
    /// The app canvas. Warm cream at the top settling through sage into olive
    /// at the very bottom — one ground for every screen. The stops are weighted
    /// so olive only arrives in the last stretch; most of the screen is the
    /// cream-to-sage transition.
    static let canvas = LinearGradient(
        stops: [
            .init(color: .heraeCream, location: 0.0),
            .init(color: .heraeSage, location: 0.45),
            .init(color: .heraeOlive, location: 1.0)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Olive fill for primary actions, the active tab and filled chips.
    static let action = LinearGradient(
        colors: [Color.heraeOlive, Color.heraeOlive.opacity(0.85)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// A softened slice of the canvas for rounded header blocks that need to
    /// read as a distinct plane from the content below them.
    static let headerBlock = LinearGradient(
        colors: [Color.heraeCream, Color.heraeSage],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
