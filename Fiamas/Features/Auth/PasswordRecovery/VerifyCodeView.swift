import SwiftUI

/// iOS-verificar-codigo (paso 2)
struct VerifyCodeView: View {
    @Environment(AppRouter.self) private var router
    @State private var code = ""

    var body: some View {
        PasswordRecoveryLayout(step: 2) {
            Text("Ingresa el codigo")
                .font(.inter(17, .bold))
                .padding(.bottom, 8)
            Text("Fiamas te ha enviado un\ncódigo, revisa tu bandeja de\nmensajes.")
                .font(.inter(14))
                .padding(.bottom, 16)

            OTPField(code: $code, boxWidth: 24, boxHeight: 32, spacing: 9)
                .frame(maxWidth: .infinity)

            Text("El codigo es de un solo uso")
                .font(.inter(10))
                .frame(maxWidth: .infinity)
                .padding(.top, 22)

            FiButton(title: "Verificar", color: .fiTealBright, height: 32) {
                router.push(.newPassword)
            }
            .padding(.top, 20)
        }
    }
}

#Preview("Paso 2") { NavigationStack { VerifyCodeView() }.environment(AppRouter()) }
