import SwiftUI

/// iOS-login-cliente
struct LoginView: View {
    @Environment(AppRouter.self) private var router
    @Environment(ProfileStore.self) private var profileStore
    
    // Callbacks para interacción fluida dentro del sheet
    var onSwitchToRegister: (() -> Void)? = nil
    var onSwitchToRecoverPassword: (() -> Void)? = nil
    var onDismiss: (() -> Void)? = nil
    
    @State private var phone = ""
    @State private var password = ""
    
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    private var canSubmit: Bool {
        phone.count == 9 && password.count == 6 && !isLoading
    }

    var body: some View {
        VStack(spacing: 0) {
            // Botón opcional para cerrar/regresar
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
                    AuthTitle(title: "¡Ingresa ya!", subtitle: "Revisa tus fiados y pagos en un solo lugar")
                        .padding(.bottom, 24)

                    VStack(spacing: 16) {
                        FiTextField(label: "Teléfono", text: $phone, placeholder: "999 999 999",
                                    icon: "phone", keyboard: .phonePad, contentType: .telephoneNumber)
                            .onChange(of: phone) { _, newValue in
                                let filtered = newValue.filter(\.isNumber)
                                if filtered.count > 9 {
                                    phone = String(filtered.prefix(9))
                                } else if filtered != newValue {
                                    phone = filtered
                                }
                            }

                        FiTextField(label: "Contraseña", text: $password, placeholder: "6 dígitos",
                                    icon: "lock", isSecure: true, contentType: .password)
                            .onChange(of: password) { _, newValue in
                                if newValue.count > 6 {
                                    password = String(newValue.prefix(6))
                                }
                            }
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
                        if let onSwitchToRecoverPassword {
                            onSwitchToRecoverPassword()
                        } else {
                            router.push(.recoverPassword)
                        }
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
                        if let onSwitchToRegister {
                            onSwitchToRegister()
                        } else {
                            router.push(.register(qrCode: nil))
                        }
                    }
                    .padding(.top, 20)
                }
                .padding(.horizontal, 28)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollDismissesKeyboard(.interactively)
        }
    }
    
    private func performLogin() async {
        isLoading = true
        errorMessage = nil
        
        let cleanPhone = phone.filter(\.isNumber)
        
        do {
            let response = try await AuthService.shared.login(
                identificador: cleanPhone,
                password: password,
                rol: "cliente"
            )
            
            print("Login exitoso para: \(response.usuario.nombre)")
            
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
