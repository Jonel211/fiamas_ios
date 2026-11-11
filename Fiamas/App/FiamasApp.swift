import SwiftUI

@main
struct FiamasApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(AppRouter())
        }
    }
}
