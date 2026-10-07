import SwiftUI

/// iOS-new-password (paso 3)
struct NewPasswordView: View {
    @Environment(AppRouter.self) private var router
    @State private var password = ""
    @State private var confirm = ""

    private var isValid: Bool { password.count >= 6 && password == confirm }

    var body: some View {
        AuthLayout(topHeight: 190, onBack: { router.pop() }) {
            StepIndicator(current: 3)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 28)

            AuthTitle(title: "¡Actualiza tu contraseña!", subtitle: "Elige una contraseña que no hayas usado antes.")
                .padding(.bottom, 24)

            VStack(spacing: 16) {
                FiTextField(label: "Nueva contraseña", text: $password, placeholder: "Mínimo 6 caracteres",
                            icon: "lock", isSecure: true, contentType: .newPassword)
                FiTextField(label: "Confirmar nueva contraseña", text: $confirm, placeholder: "Repite tu contraseña",
                            icon: "lock", isSecure: true, contentType: .newPassword)
            }

            FiButton(title: "Actualizar contraseña", isEnabled: isValid) {
                router.authPath = [.login]
            }
            .padding(.top, 28)
        }
    }
}

#Preview {
    NavigationStack { NewPasswordView() }.environment(AppRouter())
}
