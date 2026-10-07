import SwiftUI

/// iOS-recuperar-contraseña (paso 1)
struct RecoverPasswordView: View {
    @Environment(AppRouter.self) private var router
    @State private var phone = ""

    var body: some View {
        PasswordRecoveryLayout(step: 1) {
            Text("¡No te preocupes!")
                .font(.inter(17, .bold))
                .padding(.bottom, 8)
            Text("En Fiamas no pierdes nada.")
                .font(.inter(14))
                .padding(.bottom, 18)
            Text("Ingresa tu número de teléfono")
                .font(.inter(14))
                .padding(.bottom, 14)
            FiTextField(text: $phone, keyboard: .phonePad, height: 32)

            Text("Te enviaremos un codigo de\nvalidación.")
                .font(.inter(10))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.top, 20)

            FiButton(title: "Enviar", color: .fiTealBright, height: 32) {
                router.push(.verifyCode)
            }
            .padding(.top, 20)
        }
    }
}

#Preview("Paso 1") { NavigationStack { RecoverPasswordView() }.environment(AppRouter()) }
