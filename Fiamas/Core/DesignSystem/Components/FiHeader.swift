import SwiftUI

/// Barra superior verde de las pantallas internas.
struct FiHeader: View {
    enum Leading { case menu, back }

    let title: String
    var leading: Leading = .menu
    var trailingIcon: String? = "bell"
    var trailingBadge: Bool = false
    var onLeading: () -> Void = {}
    var onTrailing: () -> Void = {}

    var body: some View {
        HStack(spacing: 0) {
            iconButton(leading == .menu ? "line.3.horizontal" : "chevron.left",
                       label: leading == .menu ? "Menú" : "Atrás",
                       action: onLeading)

            Text(title)
                .font(.poppins(18, .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .frame(maxWidth: .infinity)

            if let trailingIcon {
                iconButton(trailingIcon, label: title, action: onTrailing)
                    .overlay(alignment: .topTrailing) {
                        if trailingBadge {
                            Circle()
                                .fill(Color.fiGold)
                                .frame(width: 9, height: 9)
                                .overlay(Circle().stroke(Color.fiTeal, lineWidth: 2))
                                .offset(x: -9, y: 10)
                        }
                    }
            } else {
                Color.clear.frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 8)
        .frame(height: 56)
        .frame(maxWidth: .infinity)
        .background(Color.fiTeal, ignoresSafeAreaEdges: [])
        // La zona de la barra de estado queda blanca, como en el diseño
        .background(alignment: .top) {
            Color.white
                .frame(height: 0)
                .ignoresSafeArea(edges: .top)
        }
    }

    private func iconButton(_ systemName: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}
