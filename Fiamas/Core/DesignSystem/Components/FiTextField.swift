import SwiftUI

struct FiTextField: View {
    @Binding var text: String
    var placeholder: String = ""
    var isSecure: Bool = false
    var keyboard: UIKeyboardType = .default
    var trailingIcon: String? = nil
    var height: CGFloat = 34
    var cornerRadius: CGFloat = 6

    var body: some View {
        HStack {
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboard)
                }
            }
            .font(.inter(15))
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()

            if let trailingIcon {
                Image(systemName: trailingIcon)
                    .font(.system(size: 17))
                    .foregroundStyle(.black)
            }
        }
        .padding(.horizontal, 10)
        .frame(height: height)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius).fill(.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius).stroke(Color.fiFieldBorder, lineWidth: 1)
        )
    }
}
