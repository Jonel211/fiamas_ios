import SwiftUI

/// iOS-ingreso-clientes: pantalla blanca con el logo animado al centro.
struct SplashView: View {
    @Environment(AppRouter.self) private var router
    @State private var isVisible = false
    @State private var isRotating = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            ZStack {
                // Animación de puntitos girando alrededor del logo
                ForEach(0..<8, id: \.self) { index in
                    Circle()
                        .fill(Color.fiNavy.opacity(0.85 - Double(index) * 0.09))
                        .frame(width: 10, height: 10)
                        .offset(y: -82)
                        .rotationEffect(.degrees(Double(index) * 45))
                }
                .rotationEffect(.degrees(isRotating ? 360 : 0))

                FiamasLogo(layout: .iconOnly, iconHeight: 96)
            }
            .frame(width: 170, height: 170)
            .scaleEffect(isVisible ? 1 : 0.9)
            .opacity(isVisible ? 1 : 0)
        }
        .task {
            withAnimation(.spring(duration: 0.7)) { isVisible = true }
            withAnimation(.linear(duration: 1.6).repeatForever(autoreverses: false)) {
                isRotating = true
            }
            try? await Task.sleep(for: .seconds(1.8))
            guard !Task.isCancelled else { return }
            router.phase = await AuthService.shared.restoreSession() ? .main : .auth
        }
    }
}

#Preview {
    SplashView().environment(AppRouter())
}
