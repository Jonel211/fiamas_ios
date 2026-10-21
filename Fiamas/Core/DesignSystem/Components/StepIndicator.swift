import SwiftUI

/// Indicador de pasos 1 — 2 — 3 del flujo de recuperar contraseña.
struct StepIndicator: View {
    /// Paso actual (1...total)
    let current: Int
    var total: Int = 3

    var body: some View {
        HStack(spacing: 0) {
            ForEach(1...total, id: \.self) { step in
                circle(step)
                if step < total {
                    Capsule()
                        .fill(step < current ? Color.fiGold : Color.fiBorder)
                        .frame(width: 36, height: 3)
                        .padding(.horizontal, 6)
                }
            }
        }
        .accessibilityElement()
        .accessibilityLabel("Paso \(current) de \(total)")
    }

    private func circle(_ step: Int) -> some View {
        let isDone = step < current
        let isCurrent = step == current
        return ZStack {
            Circle()
                .fill(isDone || isCurrent ? Color.fiGold : .white)
            Circle()
                .stroke(isDone || isCurrent ? Color.clear : Color.fiBorder, lineWidth: 1.5)
            if isDone {
                Image(systemName: "checkmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
            } else {
                Text("\(step)")
                    .font(.poppins(14, .semibold))
                    .foregroundStyle(isCurrent ? .white : Color.fiTextTertiary)
            }
        }
        .frame(width: 32, height: 32)
    }
}
