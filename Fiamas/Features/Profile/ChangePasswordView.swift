import SwiftUI

/// iOS-change-password
struct ChangePasswordView: View {
    @Environment(AppRouter.self) private var router
    @State private var current = ""
    @State private var newPin = ""
    @State private var confirmPin = ""

    private var canSave: Bool {
        !current.isEmpty && newPin.count == 6 && newPin == confirmPin
    }

    var body: some View {
        VStack(spacing: 0) {
            FiHeader(title: "Cambiar contraseña", leading: .back, trailingIcon: nil, onLeading: { router.pop() })

            VStack(alignment: .leading, spacing: 0) {
                Text("Para el cambio de su contraseña o PIN,\ningrese los siguientes datos")
                    .font(.poppins(10, .semibold))
                    .foregroundStyle(Color.fiTeal)
                    .padding(.bottom, 26)

                label("Contraseña / PIN")
                FiTextField(text: $current, isSecure: true, height: 36, cornerRadius: 8)

                label("Nuevo PIN (De 6 dígitos)")
                FiTextField(text: $newPin, isSecure: true, keyboard: .numberPad, height: 36, cornerRadius: 8)

                label("Confirmar PIN")
                FiTextField(text: $confirmPin, isSecure: true, keyboard: .numberPad, height: 36, cornerRadius: 8)

                Spacer()

                Button {
                    router.pop()
                } label: {
                    Text("Guardar")
                        .font(.poppins(15, .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(RoundedRectangle(cornerRadius: 6).fill(canSave ? Color.fiGold : Color.fiGoldLight))
                }
                .buttonStyle(.plain)
                .disabled(!canSave)
                .padding(.bottom, 70)
            }
            .padding(.horizontal, 42)
            .padding(.top, 26)
        }
        .background(Color.white.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private func label(_ text: String) -> some View {
        Text(text)
            .font(.poppins(15, .medium))
            .padding(.top, 8)
            .padding(.bottom, 10)
    }
}

#Preview {
    ChangePasswordView().environment(AppRouter())
}
