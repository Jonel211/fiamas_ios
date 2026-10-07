import SwiftUI

/// iOS-detalle-pago
struct PaymentDetailView: View {
    @Environment(AppRouter.self) private var router

    private let items: [(name: String, amount: String)] = [
        ("Pan", "S/ 50.00"),
        ("Arroz", "S/ 80.00"),
        ("Aceite", "S/ 90.00"),
        ("Leche evaporada x6", "S/ 50.00"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            FiHeader(title: "Detalle del pago", leading: .back, trailingIcon: nil, onLeading: { router.pop() })

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 12) {
                        IconTile(systemName: "checkmark.seal.fill", size: 48, isCircle: true)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Pago registrado")
                                .font(.poppins(17, .semibold))
                                .foregroundStyle(Color.fiTextPrimary)
                            Text("06 de sep 2026 · 4:15 pm · Efectivo")
                                .font(.poppins(13))
                                .foregroundStyle(Color.fiTextSecondary)
                        }
                    }
                    .fiCard()
                    .padding(.bottom, 24)

                    GroupLabel(title: "Productos")
                        .padding(.bottom, 8)

                    VStack(spacing: 0) {
                        ForEach(items, id: \.name) { item in
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(item.name)
                                        .font(.poppins(15, .semibold))
                                        .foregroundStyle(Color.fiTextPrimary)
                                    StatusBadge(text: "Abono víveres", foreground: .fiWarning, background: .fiGoldSoft)
                                }
                                Spacer()
                                Text(item.amount)
                                    .font(.poppins(15, .semibold))
                                    .foregroundStyle(Color.fiTextPrimary)
                            }
                            .padding(16)

                            if item.name != items.last?.name {
                                FiDivider(leadingInset: 16)
                            }
                        }
                    }
                    .fiCard(padding: 0)
                    .padding(.bottom, 24)

                    summary
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }
        }
        .fiScreenBackground()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Resumen de cuenta")
                .font(.poppins(17, .semibold))
                .foregroundStyle(Color.fiTealDark)
                .padding(.bottom, 2)

            summaryRow("Total deuda original", "S/ 270.00")
            summaryRow("Total pagado", "S/ 270.00")

            Rectangle()
                .fill(Color.fiTeal.opacity(0.25))
                .frame(height: 1)

            HStack {
                Text("Deuda restante")
                    .font(.poppins(15, .semibold))
                Spacer()
                Text("S/ 0.00")
                    .font(.poppins(20, .bold))
                    .foregroundStyle(Color.fiTeal)
            }
            .foregroundStyle(Color.fiTextPrimary)
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.fiSkySoft))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.fiSky, lineWidth: 1))
    }

    private func summaryRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(Color.fiTextSecondary)
            Spacer()
            Text(value)
                .foregroundStyle(Color.fiTextPrimary)
        }
        .font(.poppins(14))
    }
}

#Preview {
    PaymentDetailView().environment(AppRouter())
}
