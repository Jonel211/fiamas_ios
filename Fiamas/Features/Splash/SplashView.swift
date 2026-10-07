import SwiftUI

/// iOS-ingreso-clientes: pantalla blanca con el logo al centro.
struct SplashView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            FiamasLogo(layout: .iconOnly, iconHeight: 90)
        }
        .task {
            try? await Task.sleep(for: .seconds(1.8))
            router.phase = .auth
        }
    }
}

#Preview {
    SplashView().environment(AppRouter())
}
