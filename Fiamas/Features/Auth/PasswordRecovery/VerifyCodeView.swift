import SwiftUI

/// iOS-verificar-codigo (paso 2)
struct VerifyCodeView: View {
    @Environment(AppRouter.self) private var router
    @EnvironmentObject private var authViewModel: PhoneAuthViewModel
    @State private var code = ""

    var body: some View {
        AuthLayout(topHeight: 190, onBack: { router.pop() }) {
            StepIndicator(current: 2)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 28)

            AuthTitle(title: "Ingresa el código", subtitle: "Fiamas te ha enviado un código, revisa tu bandeja de mensajes.")
                .padding(.bottom, 24)

            OTPField(code: $code)

            if !authViewModel.errorMessage.isEmpty {
                Text(authViewModel.errorMessage)
                    .font(.poppins(12))
                    .foregroundStyle(.red)
                    .padding(.top, 8)
            }

            Label("El código es de un solo uso", systemImage: "info.circle")
                .font(.poppins(13))
                .foregroundStyle(Color.fiTextSecondary)
                .frame(maxWidth: .infinity)
                .padding(.top, 16)

            FiButton(title: authViewModel.isLoading ? "Verificando..." : "Verificar",
                     isEnabled: code.count == 6 && !authViewModel.isLoading) {
                authViewModel.verifyCode(otpCode: code) { success in
                    if success {
                        router.push(.newPassword)
                    }
                }
            }
            .padding(.top, 28)
        }
    }
}

#Preview {
    NavigationStack { VerifyCodeView() }.environment(AppRouter())
}
