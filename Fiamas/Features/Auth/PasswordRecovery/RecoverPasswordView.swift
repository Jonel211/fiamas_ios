import SwiftUI

struct RecoverPasswordView: View {
    @Environment(AppRouter.self) private var router
    @EnvironmentObject private var authViewModel: PhoneAuthViewModel
    
    @State private var phone = ""
    @State private var errorMessage: String? = nil

    private var canSubmit: Bool {
        phone.filter(\.isNumber).count == 9 && !authViewModel.isLoading
    }

    var body: some View {
        AuthLayout(topHeight: 190, onBack: { router.pop() }) {
            VStack(spacing: 20) {
                
                HStack(spacing: 12) {
                    StepIndicatorView(step: 1, isSelected: true)
                    Rectangle().fill(Color.fiBorder).frame(width: 30, height: 2)
                    StepIndicatorView(step: 2, isSelected: false)
                    Rectangle().fill(Color.fiBorder).frame(width: 30, height: 2)
                    StepIndicatorView(step: 3, isSelected: false)
                }
                .padding(.top, 4)

                VStack(spacing: 8) {
                    Text("¡No te preocupes!")
                        .font(.poppins(24, .bold))
                        .foregroundStyle(Color.fiTextPrimary)
                    
                    Text("En Fiamas no pierdes nada. Ingresa tu número de teléfono y te enviaremos un código de validación.")
                        .font(.poppins(14))
                        .foregroundStyle(Color.fiTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
                .padding(.top, 4)

                // Campo Teléfono con restricción estricta de 9 dígitos
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
                .padding(.top, 4)
                
                if let errorMsg = errorMessage ?? (authViewModel.errorMessage.isEmpty ? nil : authViewModel.errorMessage) {
                    Text(errorMsg)
                        .font(.poppins(12, .regular))
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 4)
                }

                FiButton(
                    title: authViewModel.isLoading ? "Enviando..." : "Enviar código",
                    isEnabled: canSubmit
                ) {
                    authViewModel.phone = phone
                    authViewModel.sendVerificationCode { success in
                        if success {
                            router.push(.verifyCode)
                        } else {
                            errorMessage = authViewModel.errorMessage
                        }
                    }
                }
                .padding(.top, 12)
            }
        }
    }
}

private struct StepIndicatorView: View {
    let step: Int
    let isSelected: Bool

    var body: some View {
        Text("\(step)")
            .font(.poppins(14, .semibold))
            .foregroundStyle(isSelected ? .white : Color.fiTextSecondary)
            .frame(width: 32, height: 32)
            .background(Circle().fill(isSelected ? Color.fiTeal : Color.gray.opacity(0.15)))
    }
}
