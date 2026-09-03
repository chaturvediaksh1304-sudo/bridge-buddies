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

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                SplashView()
            }
        }
    }
}
