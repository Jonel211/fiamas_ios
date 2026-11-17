import SwiftUI

/// iOS-new-password (paso 3)
struct NewPasswordView: View {
    @Environment(AppRouter.self) private var router
    
    var onSwitchToLogin: (() -> Void)? = nil
    var onDismiss: (() -> Void)? = nil
    
    @State private var password = ""
    @State private var confirm = ""

    private var isValid: Bool { password.count >= 6 && password == confirm }

    var body: some View {
        VStack(spacing: 0) {
            // Botón de retroceso en la parte superior izquierda dentro de la tarjeta
            if let onDismiss {
                HStack {
                    Button(action: onDismiss) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.fiNavy)
                            .padding(8)
                            .background(Circle().fill(Color.gray.opacity(0.12)))
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 4)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    StepIndicator(current: 3)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 24)

                    AuthTitle(
                        title: "¡Actualiza tu contraseña!",
                        subtitle: "Elige una contraseña que no hayas usado antes."
                    )
                    .padding(.bottom, 24)

                    VStack(spacing: 16) {
                        FiTextField(
                            label: "Nueva contraseña",
                            text: $password,
                            placeholder: "Mínimo 6 caracteres",
                            icon: "lock",
                            isSecure: true,
                            contentType: .newPassword
                        )
                        FiTextField(
                            label: "Confirmar nueva contraseña",
                            text: $confirm,
                            placeholder: "Repite tu contraseña",
                            icon: "lock",
                            isSecure: true,
                            contentType: .newPassword
                        )
                    }

                    FiButton(title: "Actualizar contraseña", isEnabled: isValid) {
                        if let onSwitchToLogin {
                            onSwitchToLogin()
                        } else {
                            router.authPath = []
                        }
                    }
                    .padding(.top, 28)
                }
                .padding(.horizontal, 28)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollDismissesKeyboard(.interactively)
        }
    }
}

#Preview {
    NavigationStack { NewPasswordView() }.environment(AppRouter())
}
