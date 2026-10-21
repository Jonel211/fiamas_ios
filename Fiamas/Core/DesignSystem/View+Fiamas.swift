import SwiftUI

extension View {
    /// Tarjeta blanca con esquinas redondeadas y sombra suave.
    func fiCard(padding: CGFloat = 16, cornerRadius: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
            )
    }

    /// Fondo gris claro de las pantallas internas.
    func fiScreenBackground(_ color: Color = .fiCanvas) -> some View {
        background(color.ignoresSafeArea())
    }
}

/// Línea divisoria fina.
struct FiDivider: View {
    var leadingInset: CGFloat = 0

    var body: some View {
        Rectangle()
            .fill(Color.fiDivider)
            .frame(height: 1)
            .padding(.leading, leadingInset)
    }
}
