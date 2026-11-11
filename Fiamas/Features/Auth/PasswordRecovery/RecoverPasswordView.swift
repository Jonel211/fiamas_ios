import SwiftUI

struct RecoverPasswordView: View {
    @Environment(AppRouter.self) private var router
    
    var onSwitchToVerifyCode: ((String) -> Void)? = nil
    var onDismiss: (() -> Void)? = nil
    
    @State private var authViewModel = PhoneAuthViewModel()
    @State private var phone = ""
    @State private var errorMessage: String? = nil

    private var canSubmit: Bool {
        phone.filter(\.isNumber).count == 9 && !authViewModel.isLoading
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
                    StepIndicator(current: 1)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 24)

                    AuthTitle(
                        title: "¡No te preocupes!",
                        subtitle: "En Fiamas no pierdes nada. Ingresa tu número de teléfono y te enviaremos un código de validación."
                    )
                    .padding(.bottom, 24)

                    FiTextField(
                        label: "Número de teléfono",
                        text: $phone,
                        placeholder: "999 999 999",
                        icon: "phone",
                        keyboard: .phonePad,
                        contentType: .telephoneNumber
                    )
                    .onChange(of: phone) { _, newValue in
                        let filtered = newValue.filter(\.isNumber)
                        if filtered.count > 9 {
                            phone = String(filtered.prefix(9))
                        } else if filtered != newValue {
                            phone = filtered
                        }
                    }

                    if let errorMsg = errorMessage ?? (authViewModel.errorMessage.isEmpty ? nil : authViewModel.errorMessage) {
                        Text(errorMsg)
                            .font(.poppins(12))
                            .foregroundStyle(.red)
                            .padding(.top, 8)
                    }

                    FiButton(
                        title: authViewModel.isLoading ? "Enviando..." : "Enviar código",
                        isEnabled: canSubmit
                    ) {
                        authViewModel.phone = phone
                        authViewModel.sendVerificationCode { success in
                            if success {
                                if let onSwitchToVerifyCode {
                                    onSwitchToVerifyCode(phone)
                                } else {
                                    router.push(.verifyCode)
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
        .environment(authViewModel)
    }
}

#Preview {
    NavigationStack { RecoverPasswordView() }.environment(AppRouter())
}
