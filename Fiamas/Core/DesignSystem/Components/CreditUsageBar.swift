import SwiftUI

/// Crédito usado frente al límite, con barra de progreso.
struct CreditUsageBar: View {
    let used: Double
    let limit: Double

    private var ratio: Double { min(1, max(0, used / max(limit, 1))) }

    private var barColor: Color {
        switch ratio {
        case ..<0.75: .fiTeal
        case ..<0.95: .fiGold
        default: .fiDanger
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                (Text(String(format: "S/ %.2f", used)).font(.poppins(13, .semibold)).foregroundColor(.fiTextPrimary)
                 + Text(String(format: "  de S/ %.2f", limit)).font(.poppins(13)).foregroundColor(.fiTextSecondary))
                Spacer()
                Text("\(Int(ratio * 100))% usado")
                    .font(.poppins(12, .medium))
                    .foregroundStyle(barColor)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.fiDivider)
                    Capsule().fill(barColor).frame(width: geo.size.width * ratio)
                }
            }
            .frame(height: 6)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Crédito usado: \(used) de \(limit) soles, \(Int(ratio * 100)) por ciento")
    }
}
