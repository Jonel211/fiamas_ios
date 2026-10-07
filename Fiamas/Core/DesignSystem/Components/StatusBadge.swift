import SwiftUI

struct StatusBadge: View {
    let text: String
    let foreground: Color
    let background: Color
    var font: Font = .inter(9, .bold)

    var body: some View {
        Text(text)
            .font(font)
            .foregroundStyle(foreground)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(RoundedRectangle(cornerRadius: 4).fill(background))
    }
}
