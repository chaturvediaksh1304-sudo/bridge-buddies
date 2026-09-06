import SwiftUI

/// Decides what the app shows at launch, from the session rather than from
/// whatever screen happened to be open last.
///
/// iOS will happily restore a scene mid-flow — after a relaunch the app was
/// coming back up on Login even when that was no longer the right place to be.
/// Deriving the root from `AuthSession.state` makes that moot: restoration can
/// suggest whatever it likes, the session decides.
struct RootView: View {
    @State private var session: AuthSession

    init(session: AuthSession) {
        _session = State(initialValue: session)
    }

    var body: some View {
        Group {
            switch session.state {
            case .loading:
                launch
            case .signedOut:
                NavigationStack { SplashView(session: session) }
            case .signedIn:
                MainTabView(session: session)
            }
        }
        .task { await session.start() }
        .animation(.spring(response: 0.4, dampingFraction: 1.0), value: session.state)
    }

    /// Shown only while the session is being restored. It is the splash
    /// *without* its call to action, so resolving to signed-out doesn't read as
    /// a screen change — the button simply arrives.
    private var launch: some View {
        ZStack {
            LinearGradient.canvas.ignoresSafeArea()
            Wordmark(size: 40, tint: .textPrimary)
        }
    }
}
