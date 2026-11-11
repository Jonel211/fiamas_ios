import SwiftUI

struct NewPasswordView: View {
    @Environment(AppRouter.self) private var router
    @EnvironmentObject private var authViewModel: PhoneAuthViewModel
    
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
        AuthLayout(topHeight: 190, onBack: { router.pop() }) {
            VStack(spacing: 20) {
                
                HStack(spacing: 12) {
                    StepIndicatorView(step: 1, isSelected: true)
                    Rectangle().fill(Color.fiTeal).frame(width: 30, height: 2)
                    StepIndicatorView(step: 2, isSelected: true)
                    Rectangle().fill(Color.fiTeal).frame(width: 30, height: 2)
                    StepIndicatorView(step: 3, isSelected: true)
                }
                .padding(.top, 4)

                VStack(spacing: 8) {
                    Text("¡Actualiza tu contraseña!")
                        .font(.poppins(24, .bold))
                        .foregroundStyle(Color.fiTextPrimary)
                    
                    Text("Ingresa una contraseña de exactamente 6 caracteres.")
                        .font(.poppins(14))
                        .foregroundStyle(Color.fiTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 4)

                // Campo Nueva Contraseña (Restringido estrictamente a 6 caracteres)
                FiTextField(
                    label: "Nueva contraseña",
                    text: $newPassword,
                    placeholder: "6 dígitos",
                    icon: "lock"
                )
                .onChange(of: newPassword) { _, newValue in
                    if newValue.count > 6 {
                        newPassword = String(newValue.prefix(6))
                    }
                }
                
                // Campo Confirmar Contraseña (Restringido estrictamente a 6 caracteres)
                FiTextField(
                    label: "Confirmar nueva contraseña",
                    text: $confirmPassword,
                    placeholder: "6 dígitos",
                    icon: "lock"
                )
                .onChange(of: confirmPassword) { _, newValue in
                    if newValue.count > 6 {
                        confirmPassword = String(newValue.prefix(6))
                    }
                }

                if let errorMsg = errorMessage ?? (authViewModel.errorMessage.isEmpty ? nil : authViewModel.errorMessage) {
                    Text(errorMsg)
                        .font(.poppins(12, .regular))
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                FiButton(
                    title: authViewModel.isLoading ? "Actualizando..." : "Actualizar contraseña",
                    isEnabled: canSubmit
                ) {
                    authViewModel.newPassword = newPassword
                    authViewModel.confirmPassword = confirmPassword
                    
                    authViewModel.updatePassword { success in
                        if success {
                            // ÉXITO: Limpia el stack de navegación y regresa directamente al Login
                            router.authPath = []
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
