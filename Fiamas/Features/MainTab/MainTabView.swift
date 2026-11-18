import SwiftUI

/// Contenedor con la barra inferior (Inicio · Mis fiados · Pagos · Perfil).
struct MainTabView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        // @Bindable nos permite crear un Binding ($) de una clase @Observable
        @Bindable var router = router
        
        VStack(spacing: 0) {
            Group {
                switch router.activeTab {
                case .home: HomeView()
                case .credits: CreditsView()
                case .payments: PaymentsView()
                case .profile: ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Le pasamos el binding del router a la barra
            MainTabBar(selected: $router.activeTab)
        }
        .fiScreenBackground()
        .toolbar(.hidden, for: .navigationBar)
        // Ya no necesitamos el .onAppear porque el router maneja la pestaña inicial
    }
}

#Preview {
    NavigationStack { MainTabView() }
        .environment(AppRouter())
        .environment(ProfileStore())
}
