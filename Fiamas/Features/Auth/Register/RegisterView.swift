import SwiftUI

/// iOS-registrarse
struct RegisterView: View {
    @Environment(AppRouter.self) private var router
    @State private var phone = ""
    @State private var fullName = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    var body: some View {
        ZStack(alignment: .top) {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                FiamasLogo(layout: .horizontal, iconHeight: 44)
                    .frame(height: 150)
                    .padding(.top, 10)

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text("Crear tu cuenta")
                                .font(.poppins(18, .bold))
                            Spacer()
                            Image(systemName: "doc.viewfinder")
                                .font(.system(size: 22))
                        }
                        .padding(.bottom, 8)

                        Text("Empieza a ver tus notas de\ncredito")
                            .font(.poppins(15))
                            .padding(.bottom, 2)

                        label("Número de celular")
                        FiTextField(text: $phone, keyboard: .phonePad)

                        label("Nombres completos")
                        FiTextField(text: $fullName, trailingIcon: "lock.shield")

                        label("Crear una contraseña")
                        FiTextField(text: $password, isSecure: true)

                        label("Confirmar contraseña")
                        FiTextField(text: $confirmPassword, isSecure: true)

                        FiButton(title: "Registrarme", color: .fiGold, font: .poppins(14, .medium)) {
                            router.push(.phoneVerification)
                        }
                        .padding(.top, 18)

                        HStack(spacing: 6) {
                            Text("¿Ya tienes una cuenta?")
                                .font(.poppins(11))
                            Button {
                                router.push(.login)
                            } label: {
                                Text("Inicia sesión")
                                    .font(.poppins(11, .semibold))
                                    .foregroundStyle(.black)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.top, 16)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 28)
                    .padding(.bottom, 30)
                }
                .scrollBounceBehavior(.basedOnSize)
                .background(
                    TopRoundedSheet(radius: 28)
                        .fill(Color.fiSky)
                        .ignoresSafeArea(edges: .bottom)
                )
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private func label(_ text: String) -> some View {
        Text(text)
            .font(.poppins(14, .medium))
            .padding(.top, 10)
            .padding(.bottom, 6)
    }
}

#Preview {
    NavigationStack { RegisterView() }.environment(AppRouter())
}
