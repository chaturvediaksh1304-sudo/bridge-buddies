import SwiftUI

#if canImport(FirebaseCore)
import FirebaseCore
#endif

@main
struct BridgeBuddiesApp: App {
    init() {
        // Guarded so the app builds and runs before the Firebase SDK is added.
        // Once it is, this is already the configure call Firebase expects at
        // launch — nothing else to wire up here.
        #if canImport(FirebaseCore)
        FirebaseApp.configure()
        #endif
    }

    /// Swap `.development()` for `.firebase(for:)` once the SDK and
     /// GoogleService-Info.plist are in the target — nothing else changes.
    @State private var session = AuthSession(auth: .development())

    var body: some Scene {
        WindowGroup {
            RootView(session: session)
        }
    }
}
