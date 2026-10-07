import SwiftUI

/// iOS-detalle-pago
struct PaymentDetailView: View {
    @Environment(AppRouter.self) private var router

    private let items: [(String, String)] = [
        ("Pan", "S/ 50.00"),
        ("Arroz", "S/ 80.00"),
        ("Aceite", "S/ 90.00"),
        ("Parangaricutirimicuaro", "S/ 50.00"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            FiHeader(title: "Detalle del pago", leading: .back, trailingIcon: nil, onLeading: { router.pop() })

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    Text("06 de sep 2026")
                        .font(.poppins(16, .medium))
                        .padding(.leading, 4)
                        .padding(.bottom, 2)

                    ForEach(items, id: \.0) { name, amount in
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(name)
                                    .font(.poppins(12, .semibold))
                                    .padding(.leading, 8)
                                Text("Abono Viveres")
                                    .font(.inter(11))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(RoundedRectangle(cornerRadius: 3).fill(Color.fiGoldChip))
                                    .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.fiGoldChipBorder, lineWidth: 0.6))
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(amount).font(.poppins(11, .semibold))
                                Text("4.15 pm").font(.poppins(11))
                                Text("Efectivo").font(.poppins(11))
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .cardStyle(cornerRadius: 6, border: .fiCardBorder)
                    }

                    summary
                        .padding(.top, 8)
                }
                .padding(.horizontal, 30)
                .padding(.top, 22)
                .padding(.bottom, 20)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Resumen de cuenta")
                .font(.poppins(15, .semibold))
                .foregroundStyle(Color.fiTeal)
                .padding(.bottom, 12)

            summaryRow("Total Deuda Original", "S/ 270.00")
                .padding(.bottom, 14)
            summaryRow("Total Pagado", "S/ 270.00")
                .padding(.bottom, 4)
            Rectangle().fill(Color.fiNavy).frame(height: 1)
                .padding(.bottom, 8)
            HStack {
                Text("Total Deuda Actual Restante")
                Spacer()
                Text("S/")
                Text("0.00").padding(.leading, 12)
            }
            .font(.inter(12))
        }
        .padding(.horizontal, 6)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(RoundedRectangle(cornerRadius: 6).fill(Color.fiSky))
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.fiSummaryBorder, lineWidth: 0.8))
    }

    private func summaryRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
        }
        .font(.inter(12))
    }
}

#Preview {
    PaymentDetailView().environment(AppRouter())
}
