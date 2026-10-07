import SwiftUI

@main
struct FiamasApp: App {
    @State private var router = AppRouter()
    @State private var profileStore = ProfileStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(router)
                .environment(profileStore)
                .preferredColorScheme(.light)
        }
    }
}
