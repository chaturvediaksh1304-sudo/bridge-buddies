import SwiftUI

/// The signed-in shell: owns the selected tab and the one `BottomTabBar` in the
/// app.
///
/// Built on `TabView` with the system bar hidden rather than a `switch` over the
/// selection, because a switch tears each screen down on every tab change —
/// scroll position, search text and filter state would all reset. The tabs stay
/// alive; only the custom bar is ours.
struct MainTabView: View {
    let session: AuthSession

    @State private var tab: AppTab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $tab) {
                HomeView()
                    .tag(AppTab.home)
                    .toolbar(.hidden, for: .tabBar)

                ChatListView()
                    .tag(AppTab.chat)
                    .toolbar(.hidden, for: .tabBar)

                CampusResourcesView()
                    .tag(AppTab.explore)
                    .toolbar(.hidden, for: .tabBar)

                ProfileView(onSignOut: { Task { await session.signOut() } })
                    .tag(AppTab.profile)
                    .toolbar(.hidden, for: .tabBar)
            }

            BottomTabBar(selected: $tab)
        }
    }
}

#Preview {
    MainTabView(session: AuthSession(auth: .development()))
}
