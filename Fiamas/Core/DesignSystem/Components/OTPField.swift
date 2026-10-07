import SwiftUI

struct OTPField: View {
    @Binding var code: String
    var length: Int = 6
    var boxWidth: CGFloat = 26
    var boxHeight: CGFloat = 33
    var spacing: CGFloat = 13
    @FocusState private var focused: Bool

    var body: some View {
        ZStack {
            TextField("", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($focused)
                .opacity(0.01)
                .onChange(of: code) { _, newValue in
                    let digits = newValue.filter(\.isNumber)
                    code = String(digits.prefix(length))
                }

            HStack(spacing: spacing) {
                ForEach(0..<length, id: \.self) { index in
                    let chars = Array(code)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(index == chars.count && focused ? Color.fiTeal : Color.fiFieldBorder, lineWidth: 1)
                        )
                        .overlay(
                            Text(index < chars.count ? String(chars[index]) : "")
                                .font(.inter(17, .semibold))
                        )
                        .frame(width: boxWidth, height: boxHeight)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { focused = true }
        }
    }
}
