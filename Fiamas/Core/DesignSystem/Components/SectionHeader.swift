import SwiftUI

/// Título de sección dentro de una pantalla.
struct SectionHeader: View {
    let title: String
    var trailing: String? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.poppins(17, .semibold))
                .foregroundStyle(Color.fiTextPrimary)
            Spacer()
            if let trailing {
                Text(trailing)
                    .font(.poppins(13))
                    .foregroundStyle(Color.fiTextSecondary)
            }
        }
    }
}

/// Título pequeño de grupo (estilo Ajustes de iOS).
struct GroupLabel: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .font(.poppins(12, .semibold))
            .tracking(0.6)
            .foregroundStyle(Color.fiTextSecondary)
            .padding(.leading, 4)
    }
}
