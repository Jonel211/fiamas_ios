import SwiftUI

/// Contenedor con la barra inferior (Inicio · Mis fiados · Pagos · Perfil).
struct MainTabView: View {
    @Environment(AppRouter.self) private var router
    @State private var tab: MainTab = .home
    @State private var didSetInitialTab = false

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch tab {
                case .home: HomeView()
                case .credits: CreditsView()
                case .payments: PaymentsView()
                case .profile: ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            MainTabBar(selected: $tab)
        }
        .background(Color.white.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            guard !didSetInitialTab else { return }
            didSetInitialTab = true
            tab = router.initialTab
        }
    }
}

#Preview {
    NavigationStack { MainTabView() }.environment(AppRouter())
}
