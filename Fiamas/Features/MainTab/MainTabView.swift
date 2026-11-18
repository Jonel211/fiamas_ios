import SwiftUI

/// Contenedor con la barra inferior (Inicio · Mis fiados · Pagos · Perfil).
struct MainTabView: View {
    @Environment(AppRouter.self) private var router
    @State private var tab: MainTab = .home
    @State private var didSetInitialTab = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                ForEach(MainTab.allCases, id: \.self) { item in
                    NavigationStack(path: Binding(
                        get: { router.mainPaths[item] ?? [] },
                        set: { router.mainPaths[item] = $0 }
                    )) {
                        section(for: item)
                            .navigationDestination(for: Route.self, destination: RootView.destination)
                    }
                    .opacity(tab == item ? 1 : 0)
                    .allowsHitTesting(tab == item)
                    .accessibilityHidden(tab != item)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if router.mainPaths[tab]?.isEmpty != false {
                MainTabBar(selected: $tab)
            }
        }
        .fiScreenBackground()
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: tab) { _, newTab in router.activeTab = newTab }
        .onAppear {
            guard !didSetInitialTab else { return }
            didSetInitialTab = true
            tab = router.initialTab
            router.activeTab = tab
        }
    }

    @ViewBuilder
    private func section(for item: MainTab) -> some View {
        switch item {
        case .home: HomeView()
        case .credits: CreditsView()
        case .payments: PaymentsView()
        case .profile: ProfileView()
        }
    }
}

#Preview {
    NavigationStack { MainTabView() }
        .environment(AppRouter())
        .environment(ProfileStore())
}
