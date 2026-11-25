import SwiftUI

/// Boleta vertical que se renderiza como imagen para compartir el comprobante.
struct PaymentReceiptView: View {
    let payment: Payment
    let customerName: String

    private var displayCustomerName: String {
        let name = customerName.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? "Cliente Fiamas" : name
    }

    private var displayProducts: [String] {
        payment.products.isEmpty ? ["Abono correspondiente a cuenta"] : payment.products
    }

    private var fiadoTotalText: String? {
        guard let total = payment.fiadoTotal else { return nil }
        return "S/ \(String(format: "%.2f", total))"
    }

    private var fiadoEstadoText: String? {
        payment.fiadoEstado?.capitalized
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ReceiptDottedDivider()
                .padding(.vertical, 18)

            metaSection

            ReceiptDottedDivider()
                .padding(.vertical, 18)

            infoSection

            ReceiptDottedDivider()
                .padding(.vertical, 18)

            summarySection

            ReceiptDottedDivider()
                .padding(.vertical, 18)

            footer
        }
        .padding(24)
        .frame(width: 380)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.fiBorder, lineWidth: 1)
        )
        .environment(\.colorScheme, .light)
    }

    private var header: some View {
        VStack(spacing: 16) {
            HStack(alignment: .center) {
                FiamasLogo(layout: .horizontal, iconHeight: 34)
                Spacer(minLength: 12)
                StatusBadge(text: "Exitoso", icon: "checkmark")
            }

            VStack(spacing: 4) {
                Text("Comprobante de pago")
                    .font(.poppins(20, .bold))
                    .foregroundStyle(Color.fiTextPrimary)
                Text("Gracias por confiar en Fiamas")
                    .font(.poppins(12))
                    .foregroundStyle(Color.fiTextSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var metaSection: some View {
        VStack(spacing: 10) {
            receiptRow(title: "Cliente", value: displayCustomerName, icon: "person.fill")
            receiptRow(title: "Fecha y hora", value: "\(payment.date) · \(payment.time)", icon: "calendar")
            if let reference = payment.reference, !reference.isEmpty {
                receiptRow(title: "Referencia", value: reference, icon: "number.square")
            }
        }
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Información del pago")
            receiptRow(title: "Tienda", value: payment.store, icon: "storefront")
            productsRow
            receiptRow(
                title: "Monto abonado",
                value: payment.amount,
                icon: "banknote",
                valueColor: .fiTeal,
                isBold: true
            )
            receiptRow(title: "Método de pago", value: payment.method, icon: "creditcard")
        }
    }

    private var productsRow: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "cart.fill")
                .font(.system(size: 14))
                .foregroundStyle(Color.fiTeal)
                .frame(width: 20)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 6) {
                Text("Productos / Detalle")
                    .font(.poppins(12))
                    .foregroundStyle(Color.fiTextSecondary)

                ForEach(displayProducts, id: \.self) { product in
                    Text("• \(product)")
                        .font(.poppins(13, .medium))
                        .foregroundStyle(Color.fiTextPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Resumen de cuenta")

            if let total = fiadoTotalText {
                summaryRow("Total fiado relacionado", total)
            }

            if let estado = fiadoEstadoText {
                summaryRow("Estado del fiado", estado)
            }

            summaryRow("Abono aplicado", payment.amount)

            Rectangle()
                .fill(Color.fiTeal.opacity(0.25))
                .frame(height: 1)

            HStack(alignment: .firstTextBaseline) {
                Text("Total abonado")
                    .font(.poppins(14, .semibold))
                Spacer(minLength: 12)
                Text(payment.amount)
                    .font(.poppins(22, .bold))
                    .foregroundStyle(Color.fiTeal)
            }
            .foregroundStyle(Color.fiTextPrimary)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.fiSkySoft))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.fiSky, lineWidth: 1))
    }

    private var footer: some View {
        VStack(spacing: 4) {
            Text("Gracias por tu pago")
                .font(.poppins(14, .semibold))
                .foregroundStyle(Color.fiTealDark)
            Text("Fiamas · Tu crédito al día")
                .font(.poppins(11))
                .foregroundStyle(Color.fiTextTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.poppins(14, .semibold))
            .foregroundStyle(Color.fiTealDark)
    }

    private func summaryRow(_ title: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .foregroundStyle(Color.fiTextSecondary)
            Spacer(minLength: 12)
            Text(value)
                .foregroundStyle(Color.fiTextPrimary)
                .multilineTextAlignment(.trailing)
        }
        .font(.poppins(12))
    }

    private func receiptRow(
        title: String,
        value: String,
        icon: String,
        valueColor: Color = .fiTextPrimary,
        isBold: Bool = false
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(Color.fiTeal)
                .frame(width: 20)
                .padding(.top, 1)

            Text(title)
                .font(.poppins(12))
                .foregroundStyle(Color.fiTextSecondary)

            Spacer(minLength: 12)

            Text(value)
                .font(.poppins(13, isBold ? .bold : .medium))
                .foregroundStyle(valueColor)
                .multilineTextAlignment(.trailing)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct ReceiptDottedDivider: View {
    var body: some View {
        ReceiptDottedLine()
            .stroke(Color.fiBorder, style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
            .frame(height: 1)
    }
}

private struct ReceiptDottedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

#Preview("Comprobante de pago") {
    PaymentReceiptView(
        payment: Payment(
            id: "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
            store: "Bodega Don Pepe",
            concept: "Abono víveres",
            products: [
                "Arroz Costeño 5 kg",
                "Aceite Primor 1 L",
                "Leche Gloria evaporada tarro 400 g por 6 unidades para completar la semana",
                "Azúcar rubia 2 kg"
            ],
            amount: "S/ 85.50",
            amountValue: 85.5,
            time: "4:15 pm",
            date: "06 de sep 2026",
            method: "Yape",
            reference: "YP-4821-9930",
            fiadoId: "fiado-01",
            fiadoTotal: 240.00,
            fiadoEstado: "pendiente"
        ),
        customerName: "María González"
    )
    .padding()
    .background(Color.fiCanvas)
}
