import SwiftUI

extension View {
    func cardStyle(cornerRadius: CGFloat = 10, border: Color = .fiCardBorder, fill: Color = .white, shadow: Bool = false) -> some View {
        self
            .background(RoundedRectangle(cornerRadius: cornerRadius).fill(fill))
            .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(border, lineWidth: 1))
            .shadow(color: shadow ? .black.opacity(0.06) : .clear, radius: 4, y: 2)
    }
}
