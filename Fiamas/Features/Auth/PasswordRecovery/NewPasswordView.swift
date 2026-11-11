import SwiftUI

struct NewPasswordView: View {
    @Environment(AppRouter.self) private var router
    @Environment(PhoneAuthViewModel.self) private var authViewModel
    
    var onSwitchToLogin: (() -> Void)? = nil
    var onDismiss: (() -> Void)? = nil
    
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String? = nil

    private var canSubmit: Bool {
        newPassword.count == 6 &&
        confirmPassword.count == 6 &&
        newPassword == confirmPassword &&
        !authViewModel.isLoading
    }

    var body: some View {
        VStack(spacing: 0) {
            // Botón de retroceso
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
                        subtitle: "Ingresa una contraseña de exactamente 6 caracteres."
                    )
                    .padding(.bottom, 24)

                    VStack(spacing: 16) {
                        FiTextField(
                            label: "Nueva contraseña",
                            text: $newPassword,
                            placeholder: "6 dígitos",
                            icon: "lock",
                            isSecure: true,
                            contentType: .newPassword
                        )
                        .onChange(of: newPassword) { _, newValue in
                            if newValue.count > 6 {
                                newPassword = String(newValue.prefix(6))
                            }
                        }
                        
                        FiTextField(
                            label: "Confirmar nueva contraseña",
                            text: $confirmPassword,
                            placeholder: "6 dígitos",
                            icon: "lock",
                            isSecure: true,
                            contentType: .newPassword
                        )
                        .onChange(of: confirmPassword) { _, newValue in
                            if newValue.count > 6 {
                                confirmPassword = String(newValue.prefix(6))
                            }
                        }
                    }

                    if let errorMsg = errorMessage ?? (authViewModel.errorMessage.isEmpty ? nil : authViewModel.errorMessage) {
                        Text(errorMsg)
                            .font(.poppins(12))
                            .foregroundStyle(.red)
                            .padding(.top, 8)
                    }

                    FiButton(
                        title: authViewModel.isLoading ? "Actualizando..." : "Actualizar contraseña",
                        isEnabled: canSubmit
                    ) {
                        authViewModel.newPassword = newPassword
                        authViewModel.confirmPassword = confirmPassword
                        
                        authViewModel.updatePassword { success in
                            if success {
                                if let onSwitchToLogin {
                                    onSwitchToLogin()
                                } else {
                                    router.authPath = []
                                }
                            } else {
                                errorMessage = authViewModel.errorMessage
                            }
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
    NavigationStack { NewPasswordView() }
        .environment(AppRouter())
        .environment(PhoneAuthViewModel())
}
