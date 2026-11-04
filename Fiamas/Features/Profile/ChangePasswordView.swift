import SwiftUI

/// iOS-change-password
struct ChangePasswordView: View {
    @Environment(AppRouter.self) private var router
    @State private var current = ""
    @State private var newPin = ""
    @State private var confirmPin = ""
    
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var showErrorAlert = false
    @State private var didSave = false

    private var pinMismatch: Bool { !confirmPin.isEmpty && newPin != confirmPin }

    // Habilita guardar solo cuando los 3 campos tienen exactamente 6 caracteres y coinciden
    private var canSave: Bool {
        current.count == 6 && newPin.count == 6 && confirmPin.count == 6 && newPin == confirmPin && !isLoading
    }

    var body: some View {
        VStack(spacing: 0) {
            FiHeader(title: "Cambiar contraseña", leading: .back, trailingIcon: nil, onLeading: { router.pop() })

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 17))
                            .foregroundStyle(Color.fiTeal)
                        Text("Para cambiar tu contraseña o PIN, ingresa los siguientes datos.")
                            .font(.poppins(14))
                            .foregroundStyle(Color.fiTealDark)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.fiTealSoft))
                    .padding(.bottom, 24)

                    VStack(spacing: 18) {
                        // 1. Contraseña / PIN actual (Acepta cualquier carácter, máx 6)
                        FiTextField(label: "Contraseña / PIN actual", text: $current, placeholder: "Tu contraseña actual",
                                    icon: "lock", isSecure: true, contentType: .password)
                            .onChange(of: current) { _, newValue in
                                if newValue.count > 6 {
                                    current = String(newValue.prefix(6))
                                }
                            }

                        // 2. Nueva contraseña / PIN (Acepta cualquier carácter, máx 6)
                        VStack(alignment: .leading, spacing: 6) {
                            FiTextField(label: "Nueva contraseña / PIN", text: $newPin, placeholder: "6 caracteres",
                                        icon: "key", isSecure: true, contentType: .newPassword)
                                .onChange(of: newPin) { _, newValue in
                                    if newValue.count > 6 {
                                        newPin = String(newValue.prefix(6))
                                    }
                                }

                            Text("Debe tener exactamente 6 caracteres.")
                                .font(.poppins(12))
                                .foregroundStyle(newPin.isEmpty || newPin.count == 6 ? Color.fiTextTertiary : Color.fiWarning)
                        }

                        // 3. Confirmar contraseña / PIN (Acepta cualquier carácter, máx 6)
                        VStack(alignment: .leading, spacing: 6) {
                            FiTextField(label: "Confirmar contraseña / PIN", text: $confirmPin, placeholder: "Repite la nueva contraseña",
                                        icon: "key", isSecure: true, contentType: .newPassword)
                                .onChange(of: confirmPin) { _, newValue in
                                    if newValue.count > 6 {
                                        confirmPin = String(newValue.prefix(6))
                                    }
                                }

                            if pinMismatch {
                                Label("Las contraseñas no coinciden", systemImage: "exclamationmark.circle")
                                    .font(.poppins(12))
                                    .foregroundStyle(Color.fiDanger)
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.white)
                            .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
                    )

                    FiButton(title: isLoading ? "Guardando..." : "Guardar", style: .accent, isEnabled: canSave) {
                        Task { await handleSave() }
                    }
                    .padding(.top, 28)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .fiScreenBackground()
        .toolbar(.hidden, for: .navigationBar)
        .alert("Contraseña actualizada", isPresented: $didSave) {
            Button("Aceptar") { router.pop() }
        } message: {
            Text("Usa tu nueva contraseña la próxima vez que ingreses.")
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("Aceptar", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "No se pudo actualizar la contraseña. Intenta nuevamente.")
        }
    }

    @MainActor
    private func handleSave() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await ProfileService.shared.changePassword(currentPassword: current, newPassword: newPin)
            didSave = true
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
        
        isLoading = false
    }
}

#Preview {
    ChangePasswordView().environment(AppRouter())
}
