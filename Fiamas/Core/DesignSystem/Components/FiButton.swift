import SwiftUI

/// Botón principal de la app.
struct FiButton: View {
    enum Style {
        /// Verde azulado (acciones de acceso y verificación)
        case primary
        /// Dorado (registrar, guardar)
        case accent
        /// Contorno verde
        case outline

        var fill: Color {
            switch self {
            case .primary: .fiTeal
            case .accent: .fiGold
            case .outline: .white
            }
        }

        var foreground: Color {
            self == .outline ? .fiTeal : .white
        }
    }

    let title: String
    var style: Style = .primary
    var icon: String? = nil
    var isEnabled: Bool = true
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(.poppins(16, .semibold))
            }
            .foregroundStyle(style.foreground)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(RoundedRectangle(cornerRadius: 14).fill(style.fill))
            .overlay {
                if style == .outline {
                    RoundedRectangle(cornerRadius: 14).stroke(Color.fiTeal, lineWidth: 1.5)
                }
            }
            .opacity(isEnabled ? 1 : 0.45)
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(!isEnabled)
    }
}

/// Leve reducción al presionar.
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
