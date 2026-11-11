import SwiftUI

struct CreditsView: View {
    @Environment(AppRouter.self) private var router
    
    @State private var fiadosAPI: [FiadoAPI] = []
    @State private var storeSummaries: [StoreSummary] = []
    @State private var isLoading = true
    @State private var hasLoadedOnce = false
    @State private var errorMessage: String? = nil
    @State private var expanded: Set<String> = []

    var mappedSections: [(store: Store, credits: [Credit])] {
        let storeNames: [String: String] = Dictionary(
            uniqueKeysWithValues: storeSummaries.map { ($0.tienda.id, $0.tienda.nombre) }
        )
        let storeLimits: [String: Double] = Dictionary(
            uniqueKeysWithValues: storeSummaries.map { ($0.tienda.id, $0.limiteCredito) }
        )
        let storeBalances: [String: Double] = Dictionary(
            uniqueKeysWithValues: storeSummaries.map { ($0.tienda.id, $0.saldoActual) }
        )

        let grouped = Dictionary(grouping: fiadosAPI) { $0.tienda?.id ?? "unknown" }

        return grouped.map { (storeId, fiados) in
            let storeName = storeNames[storeId] ?? fiados.first?.tienda?.nombre ?? "Tienda Desconocida"
            let totalPending = storeBalances[storeId] ?? fiados.reduce(0) { $0 + $1.saldoPendiente }
            let limit = storeLimits[storeId] ?? 1000

            let store = Store(
                id: storeId,
                name: storeName,
                description: "",
                date: "",
                used: totalPending,
                limit: limit
            )

            let credits = fiados.map { f in
                let uiStatus: Credit.Status = (f.estado.lowercased() == "vencido") ? .overdue : .pending
                let footnoteText = f.daysUntilDue.map { days in
                    days < 0 ? "Vencido hace \(-days) días" : (days == 0 ? "Vence hoy" : "Vence en \(days) días")
                } ?? "Saldo: S/ \(String(format: "%.2f", f.saldoPendiente))"

                return Credit(
                    amount: "S/ \(String(format: "%.2f", f.montoTotal))",
                    items: f.detalles.isEmpty ? "Fiado sin detalle" : f.detalles.map {
                        "\($0.producto?.nombre ?? "Producto") (\(Int($0.cantidad)))"
                    }.joined(separator: ", "),
                    date: String(f.fechaCreacion.prefix(10)),
                    status: uiStatus,
                    footnote: footnoteText
                )
            }
            return (store, credits)
        }
        .sorted { $0.store.name < $1.store.name }
    }

    var body: some View {
        VStack(spacing: 0) {
            FiHeader(
                title: "Mis fiados",
                trailingBadge: fiadosAPI.contains { $0.daysUntilDue.map { $0 <= 2 } ?? false },
                onLeading: { router.push(.menu) },
                onTrailing: { router.push(.notifications) }
            )

            ScrollView {
                VStack(spacing: 14) {
                    if isLoading && !hasLoadedOnce {
                        ProgressView("Cargando fiados...")
                            .padding(.top, 40)
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
                                Task { await loadDebts() }
                            }
                            .font(.poppins(14, .semibold))
                            .foregroundStyle(Color.fiTeal)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                    } else if mappedSections.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 60))
                                .foregroundStyle(Color.fiTextTertiary)
                                .padding(.top, 60)
                            Text("No tienes fiados registrados")
                                .font(.poppins(18, .semibold))
                                .foregroundStyle(Color.fiTextPrimary)
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        ForEach(mappedSections, id: \.store.id) { section in
                            StoreCreditsSectionView(
                                store: section.store,
                                credits: section.credits,
                                isExpanded: expanded.contains(section.store.id),
                                toggle: {
                                    withAnimation(.spring(duration: 0.3)) {
                                        if expanded.contains(section.store.id) {
                                            expanded.remove(section.store.id)
                                        } else {
                                            expanded.insert(section.store.id)
                                        }
                                    }
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }
            .refreshable { await loadDebts() }
        }
        .fiScreenBackground()
        .task {
            await loadDebts()
        }
    }
    
    private func loadDebts() async {
        if !hasLoadedOnce { isLoading = true }
        errorMessage = nil
        do {
            async let debts = DebtsService.shared.fetchMyDebts()
            async let summary = SummaryService.shared.fetchMySummary()
            fiadosAPI = try await debts
            let summaryResult = try await summary
            if !summaryResult.stores.isEmpty {
                storeSummaries = summaryResult.stores
            }
            if let firstStore = mappedSections.first?.store.id, expanded.isEmpty {
                expanded.insert(firstStore)
            }
            hasLoadedOnce = true
        } catch {
            print("Error cargando fiados: \(error.localizedDescription)")
            if !hasLoadedOnce {
                errorMessage = "No se pudieron cargar tus fiados. Desliza para reintentar."
            }
        }
        isLoading = false
    }
}

#Preview {
    CreditsView().environment(AppRouter())
}
