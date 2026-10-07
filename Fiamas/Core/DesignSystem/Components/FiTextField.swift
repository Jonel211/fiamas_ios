import SwiftUI

/// Campo de texto con etiqueta, ícono opcional y botón para mostrar la contraseña.
struct FiTextField: View {
    var label: String? = nil
    @Binding var text: String
    var placeholder: String = ""
    var icon: String? = nil
    var isSecure: Bool = false
    var keyboard: UIKeyboardType = .default
    var contentType: UITextContentType? = nil
    var capitalization: TextInputAutocapitalization = .never

    @FocusState private var isFocused: Bool
    @State private var isRevealed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let label {
                Text(label)
                    .font(.poppins(14, .medium))
                    .foregroundStyle(Color.fiTextPrimary)
            }

            HStack(spacing: 10) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundStyle(isFocused ? Color.fiTeal : Color.fiTextTertiary)
                        .frame(width: 20)
                }

                Group {
                    if isSecure && !isRevealed {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                            .keyboardType(keyboard)
                    }
                }
                .font(.poppins(15))
                .foregroundStyle(Color.fiTextPrimary)
                .textContentType(contentType)
                .textInputAutocapitalization(capitalization)
                .autocorrectionDisabled()
                .focused($isFocused)

                if isSecure {
                    Button {
                        isRevealed.toggle()
                    } label: {
                        Image(systemName: isRevealed ? "eye.slash" : "eye")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.fiTextTertiary)
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isRevealed ? "Ocultar contraseña" : "Mostrar contraseña")
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 50)
            .background(RoundedRectangle(cornerRadius: 12).fill(.white))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isFocused ? Color.fiTeal : Color.fiBorder, lineWidth: isFocused ? 1.5 : 1)
            )
            .animation(.easeOut(duration: 0.15), value: isFocused)
            .contentShape(Rectangle())
            .onTapGesture { isFocused = true }
        }
    }
}
