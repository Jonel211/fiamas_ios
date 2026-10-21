import SwiftUI

/// iOS-ingreso-clientes: pantalla blanca con el logo al centro.
struct SplashView: View {
    @Environment(AppRouter.self) private var router
    @State private var isVisible = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 14) {
                FiamasLogo(layout: .iconOnly, iconHeight: 96)
                Text("FIAMAS")
                    .font(.poppins(28, .bold))
                    .tracking(3)
                    .foregroundStyle(Color.fiNavy)
                Text("Tus fiados, siempre claros")
                    .font(.poppins(14))
                    .foregroundStyle(Color.fiTextSecondary)
            }
            .scaleEffect(isVisible ? 1 : 0.9)
            .opacity(isVisible ? 1 : 0)
        }
        .task {
            withAnimation(.spring(duration: 0.7)) { isVisible = true }
            try? await Task.sleep(for: .seconds(1.8))
            router.phase = .auth
        }
    }
}

#Preview {
    SplashView().environment(AppRouter())
}
