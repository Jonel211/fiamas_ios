import SwiftUI

/// iOS-login-cliente
struct LoginView: View {
    @Environment(AppRouter.self) private var router
    @Environment(ProfileStore.self) private var profileStore
    @State private var phone = ""
    @State private var password = ""
    
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    private var canSubmit: Bool {
        phone.filter(\.isNumber).count >= 9 && !password.isEmpty && !isLoading
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

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.poppins(12, .regular))
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    .transition(.opacity)
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

            FiButton(title: isLoading ? "Ingresando..." : "Ver mi cuenta", isEnabled: canSubmit) {
                Task {
                    await performLogin()
                }
            }
            .padding(.top, 24)

            AuthFooterLink(prompt: "¿No tienes una cuenta?", link: "Crear cuenta") {
                // Registro es la raíz del flujo de autenticación
                router.authPath = []
            }
            .padding(.top, 20)
        }
    }
    
    private func performLogin() async {
        isLoading = true
        errorMessage = nil
        
        // Quitamos los espacios del teléfono por si el usuario escribe "999 999 999"
        let cleanPhone = phone.filter(\.isNumber)
        
        do {
            let response = try await AuthService.shared.login(
                identificador: cleanPhone,
                password: password,
                rol: "cliente"
            )
            
            print("Login exitoso para: \(response.usuario.nombre)")
            
            // Recarga el perfil con los datos del usuario que acaba de entrar
            profileStore.reload()
            
            router.enterApp()
            
        } catch {
            withAnimation {
                errorMessage = error.localizedDescription
            }
        }
        
        isLoading = false
    }
}

#Preview {
    NavigationStack { LoginView() }
        .environment(AppRouter())
        .environment(ProfileStore())
}
