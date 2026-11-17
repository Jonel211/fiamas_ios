import SwiftUI

/// iOS-recuperar-contraseña (paso 1)
struct RecoverPasswordView: View {
    @Environment(AppRouter.self) private var router
    
    var onSwitchToVerifyCode: ((String) -> Void)? = nil
    var onDismiss: (() -> Void)? = nil
    
    @State private var phone = ""

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

                    FiButton(
                        title: "Enviar código",
                        isEnabled: phone.filter(\.isNumber).count >= 9
                    ) {
                        if let onSwitchToVerifyCode {
                            onSwitchToVerifyCode(phone)
                        } else {
                            router.push(.verifyCode)
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
    NavigationStack { RecoverPasswordView() }.environment(AppRouter())
}
