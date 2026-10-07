import SwiftUI

/// iOS-verificacion-numero
struct PhoneVerificationView: View {
    @Environment(AppRouter.self) private var router
    @State private var code = ""

    var body: some View {
        ZStack {
            Color.fiVerifyBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button { router.pop() } label: {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20))
                            .foregroundStyle(.black)
                    }
                    Spacer()
                }
                .padding(.top, 50)

                Text("Verifica tu número")
                    .font(.poppins(19, .bold))
                    .padding(.top, 48)

                Text("Te envíamos un codigo al\n+51 9xx xxx xxx")
                    .font(.poppins(11))
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)

                OTPField(code: $code, boxWidth: 26, boxHeight: 33, spacing: 13)
                    .padding(.top, 26)

                Text("¿No recibiste el codigo?")
                    .font(.poppins(12))
                    .padding(.top, 52)

                Button {
                    code = ""
                } label: {
                    Text("Reenviar Ahora")
                        .font(.poppins(11, .bold))
                        .foregroundStyle(Color.fiTeal)
                }
                .padding(.top, 10)

                FiButton(title: "Verificar", color: .fiTeal) {
                    router.enterApp()
                }
                .padding(.top, 80)

                Spacer()
            }
            .padding(.horizontal, 40)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    PhoneVerificationView().environment(AppRouter())
}
