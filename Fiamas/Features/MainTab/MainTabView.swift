import SwiftUI

/// Contenedor con la barra inferior (Inicio · Mis fiados · Pagos · Perfil).
struct MainTabView: View {
    @Environment(AppRouter.self) private var router
    @Environment(ProfileStore.self) private var profileStore
    @Environment(\.scenePhase) private var scenePhase
    @State private var tab: MainTab = .home
    @State private var didSetInitialTab = false
    @State private var debtsStore = DebtsStore()
    @State private var paymentsStore = PaymentsStore()

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
        .environment(debtsStore)
        .environment(paymentsStore)
        .toolbar(.hidden, for: .navigationBar)
        .task(id: "\(tab)-\(scenePhase)-\(router.mainPaths[tab]?.isEmpty != false)") {
            guard scenePhase == .active, router.mainPaths[tab]?.isEmpty != false else { return }
            while !Task.isCancelled {
                await refreshVisibleTab()
                try? await Task.sleep(for: RefreshPolicy.pollingInterval)
            }
        }
        .onChange(of: tab) { _, newTab in router.activeTab = newTab }
        .onAppear {
            guard !didSetInitialTab else { return }
            didSetInitialTab = true
            tab = router.initialTab
            router.activeTab = tab
        }
    }

    private func refreshVisibleTab() async {
        switch tab {
        case .home, .credits: await debtsStore.refresh(profileStore: profileStore)
        case .payments: await paymentsStore.refresh()
        case .profile: break
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
