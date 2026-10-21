import SwiftUI

/// iOS-pagos
struct PaymentsView: View {
    @Environment(AppRouter.self) private var router
    
    // Datos del servidor
    @State private var pagosAPI: [PaymentAPI] = []
    @State private var isLoading = true
    
    // Filtros
    @State private var selectedStore: String? = nil
    @State private var selectedMonth: String = ""

    // 1. Traducimos los datos de la API a los grupos que espera tu UI
    private var allGroups: [PaymentGroup] {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let monthFormatter = DateFormatter()
        monthFormatter.locale = Locale(identifier: "es_ES")
        monthFormatter.dateFormat = "MMMM yyyy"
        
        let dateTitleFormatter = DateFormatter()
        dateTitleFormatter.locale = Locale(identifier: "es_ES")
        dateTitleFormatter.dateFormat = "dd MMM yyyy"
        
        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "es_ES")
        timeFormatter.dateFormat = "h:mm a"
        
        var dict: [String: (month: String, payments: [Payment])] = [:]
        
        for api in pagosAPI {
            // Si la fecha falla, usamos la fecha actual como respaldo
            let date = isoFormatter.date(from: api.fecha_pago) ?? Date()
            
            // Título del grupo (HOY o la fecha)
            var title = "RECIENTE"
            if Calendar.current.isDateInToday(date) {
                title = "HOY"
            } else {
                title = dateTitleFormatter.string(from: date).uppercased()
            }
            
            // Mes para el filtro
            let monthString = monthFormatter.string(from: date).capitalized
            
            // Convertimos al modelo visual Payment
            let payment = Payment(
                store: api.fiado.tienda.nombre,
                concept: api.notas ?? "Abono a fiado",
                amount: "S/ \(String(format: "%.2f", api.monto))",
                time: timeFormatter.string(from: date),
                method: api.metodo_pago.capitalized
            )
            
            if dict[title] == nil {
                dict[title] = (monthString, [])
            }
            dict[title]?.payments.append(payment)
        }
        
        return dict.map { PaymentGroup(title: $0.key, month: $0.value.month, payments: $0.value.payments) }
            .sorted { $0.title == "HOY" ? true : $1.title == "HOY" ? false : $0.title > $1.title }
    }

    // 2. Listas dinámicas para los filtros
    private var stores: [String] {
        Array(Set(allGroups.flatMap { $0.payments.map(\.store) })).sorted()
    }
    
    private var months: [String] {
        Array(Set(allGroups.map { $0.month })).sorted(by: >)
    }

    // 3. Aplicamos los filtros
    private var groups: [PaymentGroup] {
        allGroups
            .filter { selectedMonth.isEmpty || $0.month == selectedMonth }
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

            if isLoading {
                ProgressView("Cargando pagos...")
                    .frame(maxHeight: .infinity)
            } else if groups.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "creditcard.trianglebadge.exclamationmark")
                        .font(.system(size: 60))
                        .foregroundStyle(Color.fiTextTertiary)
                        .padding(.top, 60)
                    Text("No hay pagos con estos filtros")
                        .font(.poppins(16, .semibold))
                        .foregroundStyle(Color.fiTextPrimary)
                }
                .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        filters
                            .padding(.bottom, 24)

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
                    .padding(.bottom, 24)
                }
            }
        }
        .fiScreenBackground()
        .task {
            await loadPayments()
        }
    }

    // 4. Filtros superiores (Ahora usan datos reales)
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
                    Button(month) { selectedMonth = month }
                }
            } label: {
                FilterPill(icon: "calendar", title: selectedMonth.isEmpty ? "Seleccionar mes" : selectedMonth)
            }
        }
    }
    
    // 5. Función para cargar los datos
    private func loadPayments() async {
        isLoading = true
        do {
            pagosAPI = try await PaymentService.shared.fetchMyPayments()
            
            // Asignar el primer mes disponible por defecto
            if selectedMonth.isEmpty, let firstMonth = months.first {
                selectedMonth = firstMonth
            }
        } catch {
            print("Error al cargar pagos: \(error.localizedDescription)")
            pagosAPI = []
        }
        isLoading = false
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
