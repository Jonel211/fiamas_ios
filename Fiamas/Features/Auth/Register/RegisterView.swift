import SwiftUI

/// iOS-registrarse
struct RegisterView: View {
    @Environment(AppRouter.self) private var router
    @State private var phone = ""
    @State private var fullName = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var lookupTask: Task<Void, Never>?
    @State private var isFound = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    private var passwordsMismatch: Bool {
        !confirmPassword.isEmpty && password != confirmPassword
    }

    private var canSubmit: Bool {
        isFound && password.count >= 6 && password == confirmPassword && !isLoading
    }

    var body: some View {
        AuthLayout(topColor: .white, sheetColor: .fiSky, logoLayout: .horizontal, topHeight: 150) {
            AuthTitle(title: "Crear tu cuenta", subtitle: "Empieza a ver tus notas de crédito")
                .padding(.bottom, 24)

            VStack(spacing: 16) {
                FiTextField(label: "Número de celular", text: $phone, placeholder: "999 999 999",
                            icon: "phone", keyboard: .phonePad, contentType: .telephoneNumber)
                    .onChange(of: phone) { _, newValue in handlePhoneChange(newValue) }

                VStack(alignment: .leading, spacing: 6) {
                    FiTextField(label: "Nombres completos", text: $fullName, placeholder: "Se completará con tu número",
                                icon: "person", contentType: .name, capitalization: .words)
                        .disabled(true)
                        .opacity(isFound ? 1 : 0.6)
                    if isFound {
                        Label("Datos registrados por tu tienda", systemImage: "checkmark.circle")
                            .font(.poppins(12))
                            .foregroundStyle(Color.secondary)
                    }
                }

                FiTextField(label: "Crear una contraseña", text: $password, placeholder: "Mínimo 6 caracteres",
                            icon: "lock", isSecure: true, contentType: .newPassword)

                VStack(alignment: .leading, spacing: 6) {
                    FiTextField(label: "Confirmar contraseña", text: $confirmPassword, placeholder: "Repite tu contraseña",
                                icon: "lock", isSecure: true, contentType: .newPassword)
                    if passwordsMismatch {
                        Label("Las contraseñas no coinciden", systemImage: "exclamationmark.circle")
                            .font(.poppins(12))
                            .foregroundStyle(Color.fiDanger)
                    }
                }
            }

            if let errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.circle")
                    .font(.poppins(12))
                    .foregroundStyle(Color.fiDanger)
                    .padding(.top, 12)
            }

            FiButton(title: "Registrarme", style: .accent, isEnabled: canSubmit) {
                Task { await register() }
            }
            .padding(.top, 28)

            AuthFooterLink(prompt: "¿Ya tienes una cuenta?", link: "Inicia sesión") {
                router.push(.login)
            }
            .padding(.top, 20)
        }
    }

    private func handlePhoneChange(_ value: String) {
        let digits = value.filter(\.isNumber)
        lookupTask?.cancel()
        errorMessage = nil

        guard digits.count == 9 else {
            fullName = ""
            isFound = false
            return
        }

        lookupTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            do {
                let r = try await AuthService.shared.preRegistro(telefono: digits)
                guard !Task.isCancelled else { return }
                if r.encontrado, let n = r.nombres, let a = r.apellidos {
                    fullName = "\(n) \(a)"
                    isFound = true
                } else {
                    fullName = ""
                    isFound = false
                    errorMessage = r.yaRegistrado == true
                        ? "Ya tienes una cuenta. Inicia sesión."
                        : "Tu tienda aún no te ha registrado. Pídele que te agregue."
                }
            } catch {
                guard !Task.isCancelled else { return }
                fullName = ""
                isFound = false
                errorMessage = error.localizedDescription
            }
        }
    }

    private func register() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await AuthService.shared.registro(telefono: phone.filter(\.isNumber), password: password)
            router.push(.login)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack { RegisterView() }.environment(AppRouter())
}
