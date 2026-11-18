import SwiftUI

/// iOS-detalle-fiado
struct CreditDetailView: View {
    @Environment(AppRouter.self) private var router
    let credit: Credit

    private var formattedTotalOriginal: String {
        credit.totalAmountValue > 0
            ? "S/ \(String(format: "%.2f", credit.totalAmountValue))"
            : credit.amount
    }

    private var formattedTotalPagado: String {
        "S/ \(String(format: "%.2f", credit.paidAmountValue))"
    }

    private var formattedTotalRestante: String {
        if credit.totalAmountValue > 0 || credit.remainingAmountValue > 0 {
            return "S/ \(String(format: "%.2f", credit.remainingAmountValue))"
        }
        return credit.amount
    }

    private var createdDateDisplay: String {
        if !credit.rawCreatedDate.isEmpty {
            return credit.rawCreatedDate
        }
        if let createdAt = credit.createdAt {
            return createdAt.replacingOccurrences(of: "Fecha: ", with: "")
        }
        return "-"
    }

    var body: some View {
        VStack(spacing: 0) {
            FiHeader(
                title: "Detalle del fiado",
                leading: .back,
                trailingIcon: nil,
                onLeading: { router.pop() }
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // MARK: - 1. Tarjeta Superior (Fiado incluido)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(credit.storeName.isEmpty ? "Fiado registrado" : credit.storeName)
                                .font(.poppins(17, .semibold))
                                .foregroundStyle(Color.fiTeal)
                            Spacer()
                            if !credit.date.isEmpty {
                                Text(credit.date)
                                    .font(.poppins(12))
                                    .foregroundStyle(Color.fiTextTertiary)
                            }
                        }

                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Creado: \(createdDateDisplay)")
                                    .font(.poppins(13))
                                    .foregroundStyle(Color.fiTextSecondary)

                                statusBadge
                            }

                            Spacer()

                            Text(formattedTotalOriginal)
                                .font(.poppins(18, .bold))
                                .foregroundStyle(Color.fiTextPrimary)
                        }
                    }
                    .fiCard()

                    // MARK: - 2. Tabla de Productos
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Productos")
                            .font(.poppins(17, .semibold))
                            .foregroundStyle(Color.fiTeal)

                        Text("CREADO: \(createdDateDisplay)")
                            .font(.poppins(11, .semibold))
                            .foregroundStyle(Color.fiTextSecondary)

                        // Cabecera de columnas
                        HStack(spacing: 8) {
                            Text("Cant.")
                                .frame(width: 54, alignment: .leading)
                            Text("Producto")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("P. Unit.")
                                .frame(width: 66, alignment: .trailing)
                            Text("Importe")
                                .frame(width: 72, alignment: .trailing)
                        }
                        .font(.poppins(12, .medium))
                        .foregroundStyle(Color.fiTextSecondary)
                        .padding(.top, 4)

                        FiDivider()

                        if credit.itemDetails.isEmpty {
                            Text(credit.items)
                                .font(.poppins(14))
                                .foregroundStyle(Color.fiTextPrimary)
                                .padding(.vertical, 8)
                        } else {
                            VStack(spacing: 0) {
                                ForEach(Array(credit.itemDetails.enumerated()), id: \.element.id) { index, item in
                                    HStack(alignment: .center, spacing: 8) {
                                        Text(item.quantityText)
                                            .font(.poppins(13))
                                            .foregroundStyle(Color.fiTextPrimary)
                                            .frame(width: 54, alignment: .leading)

                                        Text(item.name)
                                            .font(.poppins(14))
                                            .foregroundStyle(Color.fiTextPrimary)
                                            .lineLimit(2)
                                            .frame(maxWidth: .infinity, alignment: .leading)

                                        Text("S/ \(String(format: "%.2f", item.unitPrice))")
                                            .font(.poppins(13))
                                            .foregroundStyle(Color.fiTextSecondary)
                                            .frame(width: 66, alignment: .trailing)

                                        Text("S/ \(String(format: "%.2f", item.subtotal))")
                                            .font(.poppins(13, .semibold))
                                            .foregroundStyle(Color.fiTextPrimary)
                                            .frame(width: 72, alignment: .trailing)
                                    }
                                    .padding(.vertical, 10)

                                    if index < credit.itemDetails.count - 1 {
                                        FiDivider()
                                    }
                                }
                            }
                        }
                    }
                    .fiCard()

                    // MARK: - 3. Resumen de cuenta
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Resumen de cuenta")
                            .font(.poppins(17, .semibold))
                            .foregroundStyle(Color.fiTealDark)
                            .padding(.bottom, 2)

                        summaryRow("Total Deuda Original", formattedTotalOriginal)
                        summaryRow("Total Pagado", formattedTotalPagado)

                        Rectangle()
                            .fill(Color.fiTeal.opacity(0.25))
                            .frame(height: 1)

                        HStack {
                            Text("Total Deuda Actual Restante")
                                .font(.poppins(14, .bold))
                                .foregroundStyle(Color.fiTextPrimary)
                            Spacer()
                            Text(formattedTotalRestante)
                                .font(.poppins(16, .bold))
                                .foregroundStyle(Color.fiTextPrimary)
                        }
                    }
                    .padding(18)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.fiSkySoft))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.fiSky, lineWidth: 1.5))

                    // MARK: - 4. Total Deuda Final
                    HStack {
                        Text("TOTAL DEUDA")
                            .font(.poppins(16, .bold))
                            .foregroundStyle(Color.fiTextPrimary)
                        Spacer()
                        Text(formattedTotalRestante)
                            .font(.poppins(20, .bold))
                            .foregroundStyle(Color.fiOrange)
                    }
                    .padding(.horizontal, 4)
                    .padding(.top, 4)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 28)
            }
        }
        .fiScreenBackground()
        .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private var statusBadge: some View {
        switch credit.status {
        case .overdue: StatusBadge.overdue
        case .pending: StatusBadge.pending
        case .partial: StatusBadge(text: "Pago parcial", foreground: .fiWarning, background: .fiWarningSoft)
        case .paid: StatusBadge(text: "Pagado")
        case .cancelled: StatusBadge(text: "Cancelado", foreground: .fiTextSecondary, background: .fiDivider)
        }
    }

    private func summaryRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(Color.fiTextSecondary)
            Spacer()
            Text(value)
                .font(.poppins(14, .semibold))
                .foregroundStyle(Color.fiTextPrimary)
        }
        .font(.poppins(14))
    }
}
