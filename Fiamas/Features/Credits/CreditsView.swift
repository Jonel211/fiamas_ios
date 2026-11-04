import SwiftUI

struct CreditsView: View {
    @Environment(AppRouter.self) private var router
    
    @State private var fiadosAPI: [FiadoAPI] = []
    @State private var storeSummaries: [StoreSummary] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var expanded: Set<String> = []

    var mappedSections: [(store: Store, credits: [Credit])] {
        storeSummaries.map { summary in
            let fiados = fiadosAPI.filter { $0.tienda?.id == summary.tienda.id }
            let store = Store(
                id: summary.tienda.id,
                name: summary.tienda.nombre,
                description: "\(fiados.count) fiados registrados",
                date: "",
                used: summary.saldoActual,
                limit: summary.limiteCredito
            )
            let credits = fiados.map { f in
                let items = f.detalles.compactMap { detalle in
                    detalle.producto.map { "\($0.nombre) x\(String(format: "%g", detalle.cantidad))" }
                }.joined(separator: ", ")
                let status: Credit.Status
                if f.estado == "pagado" { status = .paid }
                else if f.estado == "cancelado" { status = .cancelled }
                else if (f.daysUntilDue ?? 0) < 0 { status = .overdue }
                else if f.estado == "parcial" { status = .partial }
                else { status = .pending }
                return Credit(
                    id: f.id,
                    amount: "S/ \(String(format: "%.2f", f.montoTotal))",
                    items: items.isEmpty ? "Fiado del \(f.fechaCreacion.prefix(10))" : items,
                    date: f.fechaVencimiento.map { "Vence: \($0.prefix(10))" } ?? String(f.fechaCreacion.prefix(10)),
                    status: status,
                    footnote: "\(f.estado.capitalized) · Saldo: S/ \(String(format: "%.2f", f.saldoPendiente))"
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
                trailingBadge: true,
                onLeading: { router.push(.menu) },
                onTrailing: { router.push(.notifications) }
            )

            ScrollView {
                VStack(spacing: 14) {
                    if isLoading {
                        ProgressView("Cargando fiados...")
                            .padding(.top, 40)
                    } else if let errorMessage {
                        Text(errorMessage)
                            .font(.poppins(14))
                            .foregroundStyle(Color.fiDanger)
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
        isLoading = true
        errorMessage = nil
        do {
            async let debts = DebtsService.shared.fetchMyDebts()
            async let summary = SummaryService.shared.fetchMySummary()
            fiadosAPI = try await debts
            storeSummaries = try await summary.stores
            // Expandimos la primera tienda por defecto
            if let firstStore = mappedSections.first?.store.id {
                expanded.insert(firstStore)
            }
        } catch {
            errorMessage = "No se pudieron cargar tus fiados: \(error.localizedDescription)"
        }
        isLoading = false
    }
}

#Preview {
    CreditsView().environment(AppRouter())
}
