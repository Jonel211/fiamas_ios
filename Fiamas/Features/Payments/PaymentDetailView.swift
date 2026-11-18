import SwiftUI

/// iOS-detalle-pago
struct PaymentDetailView: View {
    @Environment(AppRouter.self) private var router
    let payment: Payment?

    init(payment: Payment? = nil) {
        self.payment = payment
    }

    private var displayStore: String {
        payment?.store ?? "Bodega Don Pepe"
    }

    private var displayProducts: [String] {
        let genericPhrases = [
            "abono correspondiente a cuenta",
            "abono a cuenta",
            "abono víveres",
            "null"
        ]
        
        let filteredProducts = payment?.products.filter { product in
            let lower = product.lowercased().trimmingCharacters(in: .whitespaces)
            return !genericPhrases.contains(lower) && !lower.isEmpty
        } ?? []
        
        if !filteredProducts.isEmpty {
            return filteredProducts
        }
        
        if let concept = payment?.concept, !concept.isEmpty {
            let lowerConcept = concept.lowercased().trimmingCharacters(in: .whitespaces)
            if !genericPhrases.contains(lowerConcept) {
                if concept.contains(",") {
                    return concept.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                } else if concept.contains(" y ") {
                    return concept.components(separatedBy: " y ").map { $0.trimmingCharacters(in: .whitespaces) }
                }
                return [concept]
            }
        }
        
        return ["Abono correspondiente a cuenta"]
    }

    private var displayAmount: String {
        payment?.amount ?? "S/ 50.00"
    }

    private var displayTime: String {
        payment?.time ?? "4:15 pm"
    }

    private var displayDate: String {
        guard let p = payment, !p.date.isEmpty else { return "06 de sep 2026" }
        return p.date
    }

    private var displayMethod: String {
        payment?.method ?? "Efectivo"
    }

    private var displayReference: String? {
        payment?.reference
    }

    private var displayFiadoTotal: String? {
        guard let total = payment?.fiadoTotal else { return nil }
        return "S/ \(String(format: "%.2f", total))"
    }

    private var displayFiadoEstado: String? {
        payment?.fiadoEstado?.capitalized
    }

    private var shareReceiptText: String {
        """
        🧾 Comprobante de Abono Fiamas
        Tienda: \(displayStore)
        Productos: \(displayProducts.joined(separator: ", "))
        Monto: \(displayAmount)
        Fecha: \(displayDate) a las \(displayTime)
        Método: \(displayMethod)
        \(displayReference != nil ? "Referencia: \(displayReference!)" : "")
        Estado: Pago Registrado
        """
    }

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
                            Text("\(displayDate) · \(displayTime) · \(displayMethod)")
                                .font(.poppins(13))
                                .foregroundStyle(Color.fiTextSecondary)
                        }
                        Spacer()
                        StatusBadge(text: "Exitoso", icon: "checkmark")
                    }
                    .fiCard()
                    .padding(.bottom, 24)

                    GroupLabel(title: "Información del pago")
                        .padding(.bottom, 8)

                    VStack(spacing: 0) {
                        detailRow(title: "Tienda", value: displayStore, icon: "storefront")
                        FiDivider(leadingInset: 16)
                        
                        productsListRow
                        
                        FiDivider(leadingInset: 16)
                        detailRow(title: "Monto abonado", value: displayAmount, icon: "banknote", valueColor: .fiTeal, isBold: true)
                        FiDivider(leadingInset: 16)
                        detailRow(title: "Método de pago", value: displayMethod, icon: "creditcard")
                        
                        if let ref = displayReference, !ref.isEmpty {
                            FiDivider(leadingInset: 16)
                            detailRow(title: "Nº de referencia", value: ref, icon: "number")
                        }
                    }
                    .fiCard(padding: 0)
                    .padding(.bottom, 24)

                    summary
                        .padding(.bottom, 24)

                    ShareLink(item: shareReceiptText) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 15, weight: .semibold))
                            Text("Compartir comprobante")
                                .font(.poppins(15, .semibold))
                        }
                        .foregroundStyle(Color.fiTealDark)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.fiTealSoft))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.fiTeal.opacity(0.3), lineWidth: 1))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 28)
            }
        }
        .fiScreenBackground()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var productsListRow: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "cart.fill")
                .font(.system(size: 16))
                .foregroundStyle(Color.fiTeal)
                .frame(width: 24)
                .padding(.top, 2)

            Text("Productos / Detalle")
                .font(.poppins(14))
                .foregroundStyle(Color.fiTextSecondary)

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                ForEach(displayProducts, id: \.self) { product in
                    Text(product)
                        .font(.poppins(14, .medium))
                        .foregroundStyle(Color.fiTextPrimary)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
        .padding(16)
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Resumen de cuenta")
                .font(.poppins(17, .semibold))
                .foregroundStyle(Color.fiTealDark)
                .padding(.bottom, 2)

            if let total = displayFiadoTotal {
                summaryRow("Total fiado relacionado", total)
            }
            
            if let estado = displayFiadoEstado {
                summaryRow("Estado del fiado", estado)
            }

            summaryRow("Abono aplicado", displayAmount)

            Rectangle()
                .fill(Color.fiTeal.opacity(0.25))
                .frame(height: 1)

            HStack {
                Text("Total abonado")
                    .font(.poppins(15, .semibold))
                Spacer()
                Text(displayAmount)
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

    private func detailRow(title: String, value: String, icon: String, valueColor: Color = .fiTextPrimary, isBold: Bool = false) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Color.fiTeal)
                .frame(width: 24)

            Text(title)
                .font(.poppins(14))
                .foregroundStyle(Color.fiTextSecondary)

            Spacer()

            Text(value)
                .font(.poppins(14, isBold ? .bold : .medium))
                .foregroundStyle(valueColor)
                .multilineTextAlignment(.trailing)
        }
        .padding(16)
    }
}
