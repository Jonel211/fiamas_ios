import SwiftUI

/// iOS-pagos
struct PaymentsView: View {
    @Environment(AppRouter.self) private var router

    // Datos del servidor
    @State private var pagosAPI: [PaymentAPI] = []
    @State private var isLoading = true
    @State private var hasLoadedOnce = false
    @State private var errorMessage: String?
    @State private var refreshBannerMessage: String?

    // Filtros
    @State private var selectedStore: String? = nil
    @State private var selectedMonth: String = ""

    private static func parseDate(_ dateString: String) -> Date {
        let isoFormatterMillis = ISO8601DateFormatter()
        isoFormatterMillis.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = isoFormatterMillis.date(from: dateString) { return d }

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]
        if let d = isoFormatter.date(from: dateString) { return d }

        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        for fmt in ["yyyy-MM-dd'T'HH:mm:ss.SSSZ", "yyyy-MM-dd'T'HH:mm:ssZ", "yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd"] {
            df.dateFormat = fmt
            if let d = df.date(from: dateString) { return d }
        }

        return Date()
    }

    private var allGroups: [PaymentGroup] {
        let monthFormatter = DateFormatter()
        monthFormatter.locale = Locale(identifier: "es_ES")
        monthFormatter.dateFormat = "MMMM yyyy"

        let dateTitleFormatter = DateFormatter()
        dateTitleFormatter.locale = Locale(identifier: "es_ES")
        dateTitleFormatter.dateFormat = "dd 'de' MMM yyyy"

        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "es_ES")
        timeFormatter.dateFormat = "h:mm a"

        struct TempGroup {
            let title: String
            let month: String
            let date: Date
            var payments: [Payment]
        }

        var dict: [String: TempGroup] = [:]

        for api in pagosAPI {
            let date = Self.parseDate(api.fecha_pago)

            let title: String
            if Calendar.current.isDateInToday(date) {
                title = "HOY"
            } else if Calendar.current.isDateInYesterday(date) {
                title = "AYER"
            } else {
                title = dateTitleFormatter.string(from: date).uppercased()
            }

            let monthString = monthFormatter.string(from: date).capitalized
            let storeName = api.fiado?.tienda?.nombre ?? "Tienda"
            let conceptText = (api.notas?.isEmpty == false) ? api.notas! : "Abono a cuenta"
            let methodText = api.metodo_pago.capitalized
            let formattedAmount = "S/ \(String(format: "%.2f", api.monto))"
            let timeText = timeFormatter.string(from: date)
            let fullDateText = dateTitleFormatter.string(from: date)

            let payment = Payment(
                id: api.id,
                store: storeName,
                concept: conceptText,
                amount: formattedAmount,
                amountValue: api.monto,
                time: timeText,
                date: fullDateText,
                method: methodText,
                reference: api.referencia,
                fiadoId: api.fiado?.id,
                fiadoTotal: api.fiado?.monto_total,
                fiadoEstado: api.fiado?.estado
            )

            if dict[title] == nil {
                dict[title] = TempGroup(title: title, month: monthString, date: date, payments: [payment])
            } else {
                dict[title]?.payments.append(payment)
            }
        }

        return dict.values
            .sorted { g1, g2 in
                if g1.title == "HOY" { return true }
                if g2.title == "HOY" { return false }
                if g1.title == "AYER" { return true }
                if g2.title == "AYER" { return false }
                return g1.date > g2.date
            }
            .map { PaymentGroup(title: $0.title, month: $0.month, payments: $0.payments) }
    }

    private var stores: [String] {
        Array(Set(allGroups.flatMap { $0.payments.map(\.store) })).sorted()
    }

    private var months: [String] {
        Array(Set(allGroups.map { $0.month })).sorted(by: >)
    }

    private var groups: [PaymentGroup] {
        allGroups
            .filter { selectedMonth.isEmpty || $0.month.caseInsensitiveCompare(selectedMonth) == .orderedSame }
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
                    if let refreshBannerMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "wifi.exclamationmark")
                            Text(refreshBannerMessage)
                                .font(.poppins(12, .medium))
                            Spacer()
                        }
                        .foregroundStyle(Color.fiDanger)
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.fiDanger.opacity(0.1)))
                        .padding(.bottom, 12)
                    }

                    if isLoading && !hasLoadedOnce {
                        ProgressView("Cargando pagos...")
                            .frame(maxWidth: .infinity)
                            .padding(.top, 60)
                    } else if let errorMessage, !hasLoadedOnce {
                        VStack(spacing: 12) {
                            Image(systemName: "wifi.exclamationmark")
                                .font(.system(size: 40))
                                .foregroundStyle(Color.fiDanger)
                            Text(errorMessage)
                                .font(.poppins(14))
                                .foregroundStyle(Color.fiTextSecondary)
                                .multilineTextAlignment(.center)
                            Button("Reintentar") {
                                Task { await loadPayments() }
                            }
                            .font(.poppins(14, .semibold))
                            .foregroundStyle(Color.fiTeal)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    } else if pagosAPI.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "creditcard")
                                .font(.system(size: 56))
                                .foregroundStyle(Color.fiTextTertiary)
                                .padding(.top, 60)
                            Text("Aún no tienes pagos registrados")
                                .font(.poppins(16, .semibold))
                                .foregroundStyle(Color.fiTextPrimary)
                            Text("Tus abonos realizados en tienda aparecerán aquí.")
                                .font(.poppins(13))
                                .foregroundStyle(Color.fiTextSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        .frame(maxWidth: .infinity)
                    } else if groups.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.system(size: 56))
                                .foregroundStyle(Color.fiTextTertiary)
                                .padding(.top, 60)
                            Text("No hay pagos con estos filtros")
                                .font(.poppins(16, .semibold))
                                .foregroundStyle(Color.fiTextPrimary)
                            Button("Restablecer filtros") {
                                selectedStore = nil
                                selectedMonth = ""
                            }
                            .font(.poppins(14, .semibold))
                            .foregroundStyle(Color.fiTeal)
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        filters
                            .padding(.bottom, 24)

                        ForEach(groups) { group in
                            GroupLabel(title: group.title)
                                .padding(.bottom, 8)

                            VStack(spacing: 0) {
                                ForEach(group.payments) { payment in
                                    Button { router.push(.paymentDetail(payment)) } label: {
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
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }
            .refreshable {
                await loadPayments()
            }
        }
        .fiScreenBackground()
        .task {
            await loadPayments()
        }
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
                Button("Todos los meses") { selectedMonth = "" }
                ForEach(months, id: \.self) { month in
                    Button(month) { selectedMonth = month }
                }
            } label: {
                FilterPill(icon: "calendar", title: selectedMonth.isEmpty ? "Todos los meses" : selectedMonth)
            }
        }
    }

    private func loadPayments() async {
        if !hasLoadedOnce { isLoading = true }
        errorMessage = nil
        refreshBannerMessage = nil

        do {
            pagosAPI = try await PaymentService.shared.fetchMyPayments()
            hasLoadedOnce = true
        } catch is CancellationError {
            return
        } catch {
            if !hasLoadedOnce {
                errorMessage = "No se pudieron cargar tus pagos: \(error.localizedDescription)"
            } else {
                refreshBannerMessage = "No se pudo actualizar. Mostrando últimos datos guardados."
            }
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
