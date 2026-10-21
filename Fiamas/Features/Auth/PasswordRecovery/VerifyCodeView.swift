import SwiftUI

/// iOS-verificar-codigo (paso 2)
struct VerifyCodeView: View {
    @Environment(AppRouter.self) private var router
    @State private var code = ""

    var body: some View {
        AuthLayout(topHeight: 190, onBack: { router.pop() }) {
            StepIndicator(current: 2)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 28)

            AuthTitle(title: "Ingresa el código", subtitle: "Fiamas te ha enviado un código, revisa tu bandeja de mensajes.")
                .padding(.bottom, 24)

            OTPField(code: $code)

            Label("El código es de un solo uso", systemImage: "info.circle")
                .font(.poppins(13))
                .foregroundStyle(Color.fiTextSecondary)
                .frame(maxWidth: .infinity)
                .padding(.top, 16)

            FiButton(title: "Verificar", isEnabled: code.count == 6) {
                router.push(.newPassword)
            }
            .padding(.top, 28)
        }
    }
}

#Preview {
    NavigationStack { VerifyCodeView() }.environment(AppRouter())
}
