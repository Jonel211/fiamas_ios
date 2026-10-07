import SwiftUI

/// iOS-new-password (paso 3)
struct NewPasswordView: View {
    @Environment(AppRouter.self) private var router
    @State private var password = ""
    @State private var confirm = ""

    var body: some View {
        PasswordRecoveryLayout(step: 3) {
            Text("¡Actualiza tu contraseña!")
                .font(.inter(16, .bold))
                .padding(.bottom, 12)
            Text("Nueva contraseña")
                .font(.inter(13))
                .padding(.bottom, 10)
            FiTextField(text: $password, isSecure: true, height: 32)

            Text("Confirmar nueva contraseña")
                .font(.inter(13))
                .padding(.top, 14)
                .padding(.bottom, 10)
            FiTextField(text: $confirm, isSecure: true, height: 32)

            FiButton(title: "Actualizar contraseña", color: .fiTealBright, height: 32) {
                router.authPath = [.login]
            }
            .padding(.top, 14)
        }
    }
}

#Preview("Paso 3") { NavigationStack { NewPasswordView() }.environment(AppRouter()) }
