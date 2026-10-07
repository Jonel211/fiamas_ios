import SwiftUI

/// Ícono dentro de un cuadro redondeado de color suave.
struct IconTile: View {
    let systemName: String
    var size: CGFloat = 36
    var foreground: Color = .fiTeal
    var background: Color = .fiTealSoft
    var isCircle: Bool = false

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size * 0.44, weight: .medium))
            .foregroundStyle(foreground)
            .frame(width: size, height: size)
            .background(
                RoundedRectangle(cornerRadius: isCircle ? size / 2 : size * 0.28)
                    .fill(background)
            )
            .accessibilityHidden(true)
    }
}
