import SwiftUI

/// Código de verificación de 6 dígitos.
struct OTPField: View {
    @Binding var code: String
    var length: Int = 6
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            TextField("", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($isFocused)
                .opacity(0.01)
                .onChange(of: code) { _, newValue in
                    let digits = String(newValue.filter(\.isNumber).prefix(length))
                    if digits != newValue { code = digits }
                }

            HStack(spacing: 10) {
                ForEach(0..<length, id: \.self) { index in
                    let chars = Array(code)
                    let isCurrent = isFocused && index == min(chars.count, length - 1)
                    let isFilled = index < chars.count

                    Text(isFilled ? String(chars[index]) : "")
                        .font(.poppins(22, .semibold))
                        .foregroundStyle(Color.fiTextPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isFilled ? Color.fiTealSoft : .white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isCurrent ? Color.fiTeal : Color.fiBorder, lineWidth: isCurrent ? 1.5 : 1)
                        )
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { isFocused = true }
        }
        .onAppear { isFocused = true }
        .accessibilityElement()
        .accessibilityLabel("Código de verificación")
        .accessibilityValue(code)
    }
}
