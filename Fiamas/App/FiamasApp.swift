import SwiftUI
import FirebaseCore

@main
struct FiamasApp: App {
    @State private var router = AppRouter()
    @State private var profileStore = ProfileStore()

    init() {
        // Inicializa Firebase al arrancar la app
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(router)
                .environment(profileStore)
                .preferredColorScheme(.light)
        }
    }
}
