import SwiftUI

/// iOS-change-password
struct ChangePasswordView: View {
    @Environment(AppRouter.self) private var router
    @State private var current = ""
    @State private var newPin = ""
    @State private var confirmPin = ""
    @State private var didSave = false

    private var pinMismatch: Bool { !confirmPin.isEmpty && newPin != confirmPin }

    private var canSave: Bool {
        !current.isEmpty && newPin.count == 6 && newPin.allSatisfy(\.isNumber) && newPin == confirmPin
    }

    var body: some View {
        VStack(spacing: 0) {
            FiHeader(title: "Cambiar contraseña", leading: .back, trailingIcon: nil, onLeading: { router.pop() })

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 17))
                            .foregroundStyle(Color.fiTeal)
                        Text("Para cambiar tu contraseña o PIN, ingresa los siguientes datos.")
                            .font(.poppins(14))
                            .foregroundStyle(Color.fiTealDark)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.fiTealSoft))
                    .padding(.bottom, 24)

                    VStack(spacing: 18) {
                        FiTextField(label: "Contraseña / PIN actual", text: $current, placeholder: "Tu contraseña actual",
                                    icon: "lock", isSecure: true, contentType: .password)
                        VStack(alignment: .leading, spacing: 6) {
                            FiTextField(label: "Nuevo PIN", text: $newPin, placeholder: "6 dígitos",
                                        icon: "key", isSecure: true, keyboard: .numberPad, contentType: .newPassword)
                            Text("Debe tener exactamente 6 dígitos.")
                                .font(.poppins(12))
                                .foregroundStyle(newPin.isEmpty || newPin.count == 6 ? Color.fiTextTertiary : Color.fiWarning)
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            FiTextField(label: "Confirmar PIN", text: $confirmPin, placeholder: "Repite el nuevo PIN",
                                        icon: "key", isSecure: true, keyboard: .numberPad, contentType: .newPassword)
                            if pinMismatch {
                                Label("Los PIN no coinciden", systemImage: "exclamationmark.circle")
                                    .font(.poppins(12))
                                    .foregroundStyle(Color.fiDanger)
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.white)
                            .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
                    )

                    FiButton(title: "Guardar", style: .accent, isEnabled: canSave) {
                        didSave = true
                    }
                    .padding(.top, 28)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .fiScreenBackground()
        .toolbar(.hidden, for: .navigationBar)
        .alert("PIN actualizado", isPresented: $didSave) {
            Button("Aceptar") { router.pop() }
        } message: {
            Text("Usa tu nuevo PIN la próxima vez que ingreses.")
        }
    }
}

#Preview {
    ChangePasswordView().environment(AppRouter())
}
