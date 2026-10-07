import SwiftUI

/// iOS-registrarse
struct RegisterView: View {
    @Environment(AppRouter.self) private var router
    @State private var phone = ""
    @State private var fullName = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    private var passwordsMismatch: Bool {
        !confirmPassword.isEmpty && password != confirmPassword
    }

    private var canSubmit: Bool {
        phone.filter(\.isNumber).count >= 9 && !fullName.trimmingCharacters(in: .whitespaces).isEmpty
            && password.count >= 6 && password == confirmPassword
    }

    var body: some View {
        AuthLayout(topColor: .white, sheetColor: .fiSky, logoLayout: .horizontal, topHeight: 150) {
            AuthTitle(title: "Crear tu cuenta", subtitle: "Empieza a ver tus notas de crédito")
                .padding(.bottom, 24)

            VStack(spacing: 16) {
                FiTextField(label: "Número de celular", text: $phone, placeholder: "9xx xxx xxx",
                            icon: "phone", keyboard: .phonePad, contentType: .telephoneNumber)
                FiTextField(label: "Nombres completos", text: $fullName, placeholder: "Ej. Martha Gómez",
                            icon: "person", contentType: .name, capitalization: .words)
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

            FiButton(title: "Registrarme", style: .accent, isEnabled: canSubmit) {
                router.push(.phoneVerification)
            }
            .padding(.top, 28)

            AuthFooterLink(prompt: "¿Ya tienes una cuenta?", link: "Inicia sesión") {
                router.push(.login)
            }
            .padding(.top, 20)
        }
    }
}

#Preview {
    NavigationStack { RegisterView() }.environment(AppRouter())
}
