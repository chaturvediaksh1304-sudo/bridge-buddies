import SwiftUI

/// Press feedback for every custom control in the app.
///
/// Three things it buys us (apple-design §1, §3, §4):
/// - feedback fires on press-*down*, not on release, so a tap never feels dead;
/// - the scale settles on a critically-damped spring, so a press that is
///   interrupted or dragged away mid-flight resumes from where it actually is
///   rather than snapping back from the target value;
/// - under Reduce Motion the scale is dropped for a plain dim, which reads the
///   same intent without the vestibular movement.
///
/// Use this instead of hand-rolling `.scaleEffect(isPressed ...)` in a screen.
struct PressableStyle: ButtonStyle {
    var scale: CGFloat = 0.97

    func makeBody(configuration: Configuration) -> some View {
        PressBody(configuration: configuration, scale: scale)
    }

    private struct PressBody: View {
        let configuration: ButtonStyleConfiguration
        let scale: CGFloat
        @Environment(\.accessibilityReduceMotion) private var reduceMotion

        var body: some View {
            configuration.label
                .scaleEffect(configuration.isPressed && !reduceMotion ? scale : 1)
                .opacity(configuration.isPressed && reduceMotion ? 0.6 : 1)
                .animation(.spring(response: 0.3, dampingFraction: 1.0),
                           value: configuration.isPressed)
        }
    }
}
