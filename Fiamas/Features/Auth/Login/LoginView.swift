import SwiftUI

/// iOS-login-cliente
struct LoginView: View {
    @Environment(AppRouter.self) private var router
    @State private var phone = ""
    @State private var password = ""

    private var canSubmit: Bool {
        phone.filter(\.isNumber).count >= 9 && !password.isEmpty
    }

    var body: some View {
        AuthLayout(topColor: .fiSky, sheetColor: .white, logoLayout: .vertical, topHeight: 230) {
            AuthTitle(title: "¡Ingresa ya!", subtitle: "Revisa tus fiados y pagos en un solo lugar")
                .padding(.bottom, 28)

            VStack(spacing: 16) {
                FiTextField(label: "Teléfono", text: $phone, placeholder: "999 999 999",
                            icon: "phone", keyboard: .phonePad, contentType: .telephoneNumber)
                FiTextField(label: "Contraseña", text: $password, placeholder: "Tu contraseña",
                            icon: "lock", isSecure: true, contentType: .password)
            }

            Button {
                router.push(.recoverPassword)
            } label: {
                Text("¿Olvidaste tu contraseña?")
                    .font(.poppins(14, .medium))
                    .foregroundStyle(Color.fiTeal)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top, 14)

            FiButton(title: "Ver mi cuenta", isEnabled: canSubmit) {
                router.enterApp()
            }
            .padding(.top, 24)

            AuthFooterLink(prompt: "¿No tienes una cuenta?", link: "Crear cuenta") {
                // Registro es la raíz del flujo de autenticación
                router.authPath = []
            }
            .padding(.top, 20)
        }
    }
}

#Preview {
    NavigationStack { LoginView() }.environment(AppRouter())
}
