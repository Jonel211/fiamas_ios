import SwiftUI

/// Etiqueta en forma de píldora (estado, verificación, tipo).
struct StatusBadge: View {
    let text: String
    var icon: String? = nil
    var foreground: Color = .fiTeal
    var background: Color = .fiTealSoft

    var body: some View {
        HStack(spacing: 4) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
            }
            Text(text)
                .font(.poppins(12, .medium))
        }
        .foregroundStyle(foreground)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(Capsule().fill(background))
    }
}

extension StatusBadge {
    static let overdue = StatusBadge(text: "Vencido", foreground: .fiDanger, background: .fiDangerSoft)
    static let pending = StatusBadge(text: "Pendiente", foreground: .fiWarning, background: .fiWarningSoft)
}
