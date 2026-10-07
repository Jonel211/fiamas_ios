import SwiftUI

/// Tarjeta desplegable de una tienda con sus fiados.
struct StoreCreditsSectionView: View {
    let store: Store
    let credits: [Credit]
    let isExpanded: Bool
    let toggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: toggle) {
                HStack(spacing: 12) {
                    IconTile(systemName: "storefront", size: 44)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(store.name)
                            .font(.poppins(16, .semibold))
                            .foregroundStyle(Color.fiTextPrimary)
                        Text(credits.isEmpty ? "Sin fiados" : "\(credits.count) \(credits.count == 1 ? "fiado" : "fiados")")
                            .font(.poppins(13))
                            .foregroundStyle(Color.fiTextSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.fiTeal)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(Color.fiTealSoft))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityHint(isExpanded ? "Ocultar fiados" : "Mostrar fiados")

            if isExpanded {
                CreditUsageBar(used: store.used, limit: store.limit)
                    .padding(.top, 16)

                if credits.isEmpty {
                    Text("No tienes fiados en esta tienda")
                        .font(.poppins(14))
                        .foregroundStyle(Color.fiTextSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                        .padding(.bottom, 4)
                } else {
                    VStack(spacing: 0) {
                        ForEach(credits) { credit in
                            FiDivider()
                            CreditCardView(credit: credit)
                        }
                    }
                    .padding(.top, 14)
                }
            }
        }
        .fiCard()
    }
}
