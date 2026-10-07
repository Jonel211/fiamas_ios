import SwiftUI

/// iOS-recuperar-contraseña (paso 1)
struct RecoverPasswordView: View {
    @Environment(AppRouter.self) private var router
    @State private var phone = ""

    var body: some View {
        AuthLayout(topHeight: 190, onBack: { router.pop() }) {
            StepIndicator(current: 1)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 28)

            AuthTitle(title: "¡No te preocupes!", subtitle: "En Fiamas no pierdes nada. Ingresa tu número de teléfono y te enviaremos un código de validación.")
                .padding(.bottom, 24)

            FiTextField(label: "Número de teléfono", text: $phone, placeholder: "9xx xxx xxx",
                        icon: "phone", keyboard: .phonePad, contentType: .telephoneNumber)

            FiButton(title: "Enviar código", isEnabled: phone.filter(\.isNumber).count >= 9) {
                router.push(.verifyCode)
            }
            .padding(.top, 28)
        }
    }
}

#Preview {
    NavigationStack { RecoverPasswordView() }.environment(AppRouter())
}
