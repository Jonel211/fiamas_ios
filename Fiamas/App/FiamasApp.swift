import SwiftUI

@main
struct FiamasApp: App {
    @State private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(router)
                .preferredColorScheme(.light)
        }
    }
}
