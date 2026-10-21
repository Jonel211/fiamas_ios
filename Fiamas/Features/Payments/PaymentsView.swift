import SwiftUI

/// iOS-pagos
struct PaymentsView: View {
    @Environment(AppRouter.self) private var router
    @State private var selectedStore: String? = nil
    @State private var selectedMonth = "septiembre 2026"

    private let allGroups = PaymentGroup.samples
    private let months = ["septiembre 2026", "agosto 2026", "julio 2026"]

    private var stores: [String] {
        Array(Set(allGroups.flatMap { $0.payments.map(\.store) })).sorted()
    }

    /// Grupos filtrados por mes y tienda.
    private var groups: [PaymentGroup] {
        allGroups
            .filter { $0.month == selectedMonth }
            .compactMap { group in
                guard let selectedStore else { return group }
                let payments = group.payments.filter { $0.store == selectedStore }
                return payments.isEmpty ? nil : PaymentGroup(title: group.title, month: group.month, payments: payments)
            }
    }

    var body: some View {
        VStack(spacing: 0) {
            FiHeader(
                title: "Pagos",
                trailingBadge: true,
                onLeading: { router.push(.menu) },
                onTrailing: { router.push(.notifications) }
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    filters
                        .padding(.bottom, 24)

                    if groups.isEmpty {
                        Text("No hay pagos con estos filtros")
                            .font(.poppins(14))
                            .foregroundStyle(Color.fiTextSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                    }

                    ForEach(groups) { group in
                        GroupLabel(title: group.title)
                            .padding(.bottom, 8)

                        VStack(spacing: 0) {
                            ForEach(group.payments) { payment in
                                Button { router.push(.paymentDetail) } label: {
                                    PaymentRowView(payment: payment)
                                }
                                .buttonStyle(.plain)

                                if payment.id != group.payments.last?.id {
                                    FiDivider(leadingInset: 56)
                                }
                            }
                        }
                        .fiCard(padding: 0)
                        .padding(.bottom, 24)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .fiScreenBackground()
    }

    private var filters: some View {
        HStack(spacing: 12) {
            Menu {
                Button("Todas las tiendas") { selectedStore = nil }
                ForEach(stores, id: \.self) { store in
                    Button(store) { selectedStore = store }
                }
            } label: {
                FilterPill(icon: "storefront", title: selectedStore ?? "Todas las tiendas")
            }

            Menu {
                ForEach(months, id: \.self) { month in
                    Button(month.capitalized) { selectedMonth = month }
                }
            } label: {
                FilterPill(icon: "calendar", title: selectedMonth.capitalized)
            }
        }
    }
}

/// Botón de filtro con ícono y flecha.
private struct FilterPill: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(Color.fiTeal)
            Text(title)
                .font(.poppins(13, .medium))
                .foregroundStyle(Color.fiTextPrimary)
                .lineLimit(1)
            Spacer(minLength: 2)
            Image(systemName: "chevron.down")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.fiTextSecondary)
        }
        .padding(.horizontal, 12)
        .frame(height: 44)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 12).fill(.white))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.fiBorder, lineWidth: 1))
    }
}

#Preview {
    PaymentsView().environment(AppRouter())
}
