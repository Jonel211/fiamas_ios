import SwiftUI

/// iOS-login-cliente
struct LoginView: View {
    @Environment(AppRouter.self) private var router
    @State private var phone = ""
    @State private var password = ""

    var body: some View {
        ZStack(alignment: .top) {
            Color.fiSky.ignoresSafeArea()

            VStack(spacing: 0) {
                FiamasLogo(layout: .vertical, iconHeight: 64)
                    .frame(height: 210)
                    .padding(.top, 20)

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("¡Ingresa ya!")
                            .font(.inter(17, .bold))
                            .padding(.bottom, 22)

                        Text("Teléfono")
                            .font(.inter(14))
                            .padding(.bottom, 12)
                        FiTextField(text: $phone, keyboard: .phonePad)

                        Text("Contraseña")
                            .font(.inter(14))
                            .padding(.top, 18)
                            .padding(.bottom, 12)
                        FiTextField(text: $password, isSecure: true)

                        Button {
                            router.push(.recoverPassword)
                        } label: {
                            Text("¿Olvidaste tu contraseña?")
                                .font(.inter(11, .semibold))
                                .foregroundStyle(.black)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.top, 22)

                        FiButton(title: "Ver mi cuenta", color: .fiTeal) {
                            router.enterApp()
                        }
                        .padding(.top, 20)

                        HStack(spacing: 6) {
                            Text("¿No tienes una cuenta?")
                                .font(.inter(12))
                            Button {
                                // Registro es la raíz del flujo de autenticación
                                router.authPath = []
                            } label: {
                                Text("Crear cuenta")
                                    .font(.inter(12, .semibold))
                                    .foregroundStyle(Color.fiTeal)
                                    .underline()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 16)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 36)
                    .padding(.bottom, 40)
                }
                .scrollBounceBehavior(.basedOnSize)
                .background(
                    TopRoundedSheet(radius: 30)
                        .fill(.white)
                        .ignoresSafeArea(edges: .bottom)
                )
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    LoginView().environment(AppRouter())
}
