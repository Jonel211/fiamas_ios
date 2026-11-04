import SwiftUI

/// iOS-recuperar-contraseña (paso 1)
struct RecoverPasswordView: View {
    @Environment(AppRouter.self) private var router
    @State private var authViewModel = PhoneAuthViewModel()

    var body: some View {
        AuthLayout(topHeight: 190, onBack: { router.pop() }) {
            StepIndicator(current: 1)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 28)

            AuthTitle(title: "¡No te preocupes!", subtitle: "En Fiamas no pierdes nada. Ingresa tu número de teléfono y te enviaremos un código de validación.")
                .padding(.bottom, 24)

            FiTextField(label: "Número de teléfono", text: $authViewModel.phone, placeholder: "999 999 999",
                        icon: "phone", keyboard: .phonePad, contentType: .telephoneNumber)

            if !authViewModel.errorMessage.isEmpty {
                Text(authViewModel.errorMessage)
                    .font(.poppins(12))
                    .foregroundStyle(.red)
                    .padding(.top, 8)
            }

            FiButton(title: authViewModel.isLoading ? "Enviando..." : "Enviar código",
                     isEnabled: authViewModel.phone.filter(\.isNumber).count >= 9 && !authViewModel.isLoading) {
                authViewModel.sendVerificationCode { success in
                    if success {
                        router.push(.verifyCode)
                    }
                }
            }
            .padding(.top, 28)
        }
        .environment(authViewModel)
    }
}

#Preview {
    NavigationStack { RecoverPasswordView() }.environment(AppRouter())
}
