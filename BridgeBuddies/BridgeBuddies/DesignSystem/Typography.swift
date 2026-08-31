import SwiftUI

// MARK: - Bridge Buddies Typography
//
// Display = serif (Playfair Display), UI = system sans. Herae itself is sans
// throughout; the serif is kept here for screen titles and the wordmark because
// it is Bridge Buddies' one distinctive brand element.
//
// Scale follows Herae's 12/16/20/24/28/32/40 step. Tracking on the display
// sizes is negative and size-derived — a serif set large reads too loose at the
// tracking that suits it small (apple-design §15).
//
// Add "PlayfairDisplay-Bold" / "PlayfairDisplay-Regular" to the target and
// Info.plist's UIAppFonts before these .custom() calls resolve; falls back to
// the system serif otherwise.

extension Font {
    /// Playfair when it's installed, the system serif when it isn't.
    ///
    /// `Font.custom` with a missing family falls back to the system *sans*,
    /// which silently erases the display face everywhere. Checking first keeps
    /// the serif intent on a machine without the font, and upgrades on its own
    /// once PlayfairDisplay-Bold is added to the target and UIAppFonts.
    static func displayFont(size: CGFloat, weight: Font.Weight = .bold) -> Font {
        if UIFont(name: "PlayfairDisplay-Bold", size: size) != nil {
            return .custom("PlayfairDisplay-Bold", size: size)
        }
        return .system(size: size, weight: weight, design: .serif)
    }

    static let displayLG = displayFont(size: 40)   // splash logo
    static let displayMD = displayFont(size: 32)   // screen titles
    static let displaySM = displayFont(size: 28)   // greetings
    static let displayXS = displayFont(size: 24)   // card titles

    static let titleMD = Font.system(size: 24, weight: .regular)   // section heads
    static let bodyLG = Font.system(size: 20, weight: .medium)     // field values, list primary
    static let bodyMD = Font.system(size: 16, weight: .regular)    // field labels, secondary
    static let bodySM = Font.system(size: 12, weight: .regular)    // helper text, timestamps
    static let caption = Font.system(size: 12, weight: .medium)    // eyebrow, uppercase tracked
}

extension View {
    /// Size-derived negative tracking for display serif text.
    func displayTracking(_ size: CGFloat) -> some View {
        self.tracking(size * -0.02)
    }
}
