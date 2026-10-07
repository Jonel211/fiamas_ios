import SwiftUI

/// Hoja con esquinas superiores redondeadas usada en registro, login y recuperar contraseña.
struct TopRoundedSheet: Shape {
    var radius: CGFloat = 28

    func path(in rect: CGRect) -> Path {
        Path(
            roundedRect: rect,
            cornerRadii: RectangleCornerRadii(topLeading: radius, bottomLeading: 0, bottomTrailing: 0, topTrailing: radius)
        )
    }
}
