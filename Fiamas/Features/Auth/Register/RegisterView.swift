import SwiftUI

/// iOS-registrarse
struct RegisterView: View {
    @Environment(AppRouter.self) private var router
    var qrCode: String? = nil
    @State private var phone = ""
    @State private var fullName = ""
    @State private var lastName = ""
    @State private var address = ""
    @State private var autofilledAddress: String?
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var lookupTask: Task<Void, Never>?
    @State private var isFound = false
    @State private var isAlreadyRegistered = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    private var passwordsMismatch: Bool {
        !confirmPassword.isEmpty && password != confirmPassword
    }

    private var phoneDigits: String {
        phone.filter { $0.isASCII && $0.isNumber }
    }

    private var canSubmit: Bool {
        phoneDigits.count == 9 && !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && (isFound || (qrCode != nil
            && !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty))
            && !isAlreadyRegistered && password.count >= 6 && password == confirmPassword && !isLoading
    }

    var body: some View {
        AuthLayout(topColor: .white, sheetColor: .fiSky, logoLayout: .horizontal, topHeight: 150) {
            AuthTitle(title: "Crear tu cuenta", subtitle: "Empieza a ver tus notas de crédito")
                .padding(.bottom, 24)

            if qrCode != nil {
                Label("Código QR de tienda escaneado", systemImage: "qrcode")
                    .font(.poppins(13, .medium))
                    .foregroundStyle(Color.fiTeal)
                    .padding(.bottom, 16)
            }

            VStack(spacing: 16) {
                FiTextField(label: "Número de celular", text: $phone, placeholder: "999 999 999",
                            icon: "phone", keyboard: .phonePad, contentType: .telephoneNumber)
                    .onChange(of: phone) { _, newValue in
                        let digits = String(newValue.filter { $0.isASCII && $0.isNumber }.prefix(9))
                        if newValue != digits { phone = digits }
                        handlePhoneChange(digits)
                    }

                VStack(alignment: .leading, spacing: 6) {
                    FiTextField(label: qrCode == nil ? "Nombres completos" : "Nombres", text: $fullName,
                                placeholder: qrCode == nil ? "Se completará con tu número" : "Se completará con tu número o escríbelo",
                                icon: "person", contentType: .name, capitalization: .words)
                        .disabled(qrCode == nil || isFound)
                        .opacity(isFound || qrCode != nil ? 1 : 0.6)
                    if isFound {
                        Label("Datos registrados por tu tienda", systemImage: "checkmark.circle")
                            .font(.poppins(12))
                            .foregroundStyle(Color.secondary)
                    }
                }

                if qrCode != nil {
                    FiTextField(label: "Apellidos", text: $lastName, placeholder: "Tus apellidos",
                                icon: "person", contentType: .familyName, capitalization: .words)
                        .disabled(isFound)
                }

                FiTextField(label: "Dirección", text: $address, placeholder: "Tu dirección",
                            icon: "mappin.and.ellipse", contentType: .fullStreetAddress, capitalization: .sentences)

                FiTextField(label: "Crear una contraseña", text: $password, placeholder: "Mínimo 6 caracteres",
                            icon: "lock", isSecure: true, contentType: .newPassword)
                if !password.isEmpty && password.count < 6 {
                    Label("La contraseña debe tener al menos 6 caracteres", systemImage: "exclamationmark.circle")
                        .font(.poppins(12))
                        .foregroundStyle(Color.fiDanger)
                }

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
        let digits = value
        lookupTask?.cancel()
        errorMessage = nil
        isAlreadyRegistered = false
        if address == autofilledAddress { address = "" }
        autofilledAddress = nil
        if isFound {
            fullName = ""
            lastName = ""
            isFound = false
        }

        guard digits.count == 9 else {
            if qrCode == nil || isFound {
                fullName = ""
                lastName = ""
            }
            isFound = false
            return
        }

        lookupTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            do {
                let r = try await AuthService.shared.preRegistro(telefono: digits)
                guard !Task.isCancelled else { return }
                isAlreadyRegistered = r.yaRegistrado == true
                if r.encontrado, let n = r.nombres, let a = r.apellidos {
                    fullName = qrCode == nil ? "\(n) \(a)" : n
                    lastName = a
                    if address.isEmpty, let savedAddress = r.direccion {
                        address = savedAddress
                        autofilledAddress = savedAddress
                    }
                    isFound = true
                } else {
                    if qrCode == nil {
                        fullName = ""
                        lastName = ""
                    }
                    isFound = false
                    errorMessage = r.yaRegistrado == true
                        ? "Ya tienes una cuenta. Inicia sesión."
                        : qrCode == nil ? "Tu tienda aún no te ha registrado. Pídele que te agregue." : nil
                }
            } catch {
                guard !Task.isCancelled else { return }
                if qrCode == nil {
                    fullName = ""
                    lastName = ""
                }
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
            try await AuthService.shared.registro(telefono: phoneDigits, password: password, direccion: address,
                                                  nombres: qrCode == nil ? nil : fullName,
                                                  apellidos: qrCode == nil ? nil : lastName, qrCode: qrCode)
            router.push(.login)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack { RegisterView() }.environment(AppRouter())
}
