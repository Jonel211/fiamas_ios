import SwiftUI

/// iOS-verificar-codigo (paso 2)
struct VerifyCodeView: View {
    @Environment(AppRouter.self) private var router
    @Environment(PhoneAuthViewModel.self) private var authViewModel
    
    var initialPhone: String = ""
    var onSwitchToNewPassword: (() -> Void)? = nil
    var onDismiss: (() -> Void)? = nil
    
    @State private var code = ""

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
                    StepIndicator(current: 2)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 24)

                    AuthTitle(
                        title: "Ingresa el código",
                        subtitle: "Fiamas te ha enviado un código, revisa tu bandeja de mensajes."
                    )
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

                    FiButton(
                        title: authViewModel.isLoading ? "Verificando..." : "Verificar",
                        isEnabled: code.count == 6 && !authViewModel.isLoading
                    ) {
                        authViewModel.verifyCode(otpCode: code) { success in
                            if success {
                                if let onSwitchToNewPassword {
                                    onSwitchToNewPassword()
                                } else {
                                    router.push(.newPassword)
                                }
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
    NavigationStack { VerifyCodeView() }
        .environment(AppRouter())
        .environment(PhoneAuthViewModel())
}
