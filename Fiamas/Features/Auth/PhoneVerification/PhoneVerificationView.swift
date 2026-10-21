import SwiftUI

/// iOS-verificacion-numero
struct PhoneVerificationView: View {
    @Environment(AppRouter.self) private var router
    @State private var code = ""
    @State private var secondsLeft = 30

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { router.pop() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.fiTextPrimary)
                        .frame(width: 42, height: 42)
                        .background(Circle().fill(.white))
                        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Atrás")
                Spacer()
            }
            .padding(.top, 8)

            IconTile(systemName: "message.badge", size: 72, isCircle: true)
                .padding(.top, 28)

            Text("Verifica tu número")
                .font(.poppins(26, .bold))
                .foregroundStyle(Color.fiTextPrimary)
                .padding(.top, 20)

            (Text("Te enviamos un código de 6 dígitos al\n")
             + Text("+51 999 999 999").font(.poppins(15, .semibold)).foregroundColor(.fiTextPrimary))
                .font(.poppins(15))
                .foregroundStyle(Color.fiTextSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.top, 8)

            OTPField(code: $code)
                .padding(.top, 32)

            resend
                .padding(.top, 28)

            Spacer()

            FiButton(title: "Verificar", isEnabled: code.count == 6) {
                router.enterApp()
            }
            .padding(.bottom, 16)
        }
        .padding(.horizontal, 24)
        .background(Color.fiCanvas.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .task(id: secondsLeft) {
            guard secondsLeft > 0 else { return }
            try? await Task.sleep(for: .seconds(1))
            secondsLeft -= 1
        }
    }

    @ViewBuilder
    private var resend: some View {
        VStack(spacing: 6) {
            Text("¿No recibiste el código?")
                .font(.poppins(14))
                .foregroundStyle(Color.fiTextSecondary)
            if secondsLeft > 0 {
                Text("Reenviar en 0:\(String(format: "%02d", secondsLeft))")
                    .font(.poppins(14, .medium))
                    .foregroundStyle(Color.fiTextTertiary)
                    .monospacedDigit()
            } else {
                Button {
                    code = ""
                    secondsLeft = 30
                } label: {
                    Text("Reenviar ahora")
                        .font(.poppins(14, .semibold))
                        .foregroundStyle(Color.fiTeal)
                }
            }
        }
    }
}

#Preview {
    NavigationStack { PhoneVerificationView() }.environment(AppRouter())
}
