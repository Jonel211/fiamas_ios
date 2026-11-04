import SwiftUI

/// iOS-inicio
struct HomeView: View {
    @Environment(AppRouter.self) private var router
    @Environment(ProfileStore.self) private var profileStore

    // Datos del servidor
    @State private var fiadosAPI: [FiadoAPI] = []
    @State private var storeSummaries: [StoreSummary] = []
    @State private var clientScore: Int?
    @State private var clientCategory: String = "Sin historial"
    @State private var totalOwed: Double = 0
    @State private var errorMessage: String?
    @State private var isLoading = true

    private var mappedStores: [Store] {
        storeSummaries.map { summary in
            let fiados = fiadosAPI.filter { $0.tienda?.id == summary.tienda.id }
            return Store(
                id: summary.tienda.id,
                name: summary.tienda.nombre,
                description: "\(fiados.count) fiados registrados",
                date: fiados.first.map { String($0.fechaCreacion.prefix(10)) } ?? "",
                used: summary.saldoActual,
                limit: summary.limiteCredito
            )
        }
        .sorted { $0.name < $1.name }
    }

    var body: some View {
        VStack(spacing: 0) {
            FiHeader(
                title: "Bienvenido",
                trailingBadge: fiadosAPI.contains { $0.daysUntilDue.map { $0 <= 2 } ?? false },
                onLeading: { router.push(.menu) },
                onTrailing: { router.push(.notifications) }
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Hola, \(profileStore.profile.firstName)")
                        .font(.poppins(22, .semibold))
                        .foregroundStyle(Color.fiTextPrimary)
                    Text("Este es el resumen de tus fiados")
                        .font(.poppins(14))
                        .foregroundStyle(Color.fiTextSecondary)
                        .padding(.bottom, 16)

                    if isLoading {
                        ProgressView("Cargando...")
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                    } else if let errorMessage {
                        Text(errorMessage)
                            .font(.poppins(14))
                            .foregroundStyle(Color.fiDanger)
                            .padding(.top, 24)
                    } else {
                        TotalOwedCard(total: String(format: "%.2f", totalOwed), score: clientScore, category: clientCategory)
                            .padding(.bottom, 28)

                        SectionHeader(title: "Tiendas recientes", trailing: "\(mappedStores.count) tiendas")
                            .padding(.bottom, 12)

                        if mappedStores.isEmpty {
                            VStack(spacing: 10) {
                                Image(systemName: "cart.badge.questionmark")
                                    .font(.system(size: 40))
                                    .foregroundStyle(Color.fiTextTertiary)
                                Text("Aún no tienes fiados activos.")
                                    .font(.poppins(14, .medium))
                                    .foregroundStyle(Color.fiTextSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 20)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(mappedStores) { store in
                                    StoreCardView(store: store)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }
            .refreshable {
                await loadData()
            }
        }
        .fiScreenBackground()
        .task {
            await loadData()
        }
    }
    
    private func loadData() async {
        isLoading = true
        errorMessage = nil
        async let debtsTask = DebtsService.shared.fetchMyDebts()
        async let summaryTask = SummaryService.shared.fetchMySummary()
        do {
            fiadosAPI = try await debtsTask
            let summary = try await summaryTask
            storeSummaries = summary.stores
            totalOwed = summary.totalOwed
            clientScore = summary.score
            clientCategory = summary.category
            profileStore.updateScoring(score: clientScore, category: clientCategory)
            await ReminderScheduler.sync(fiadosAPI)
        } catch {
            errorMessage = "No se pudo cargar tu resumen: \(error.localizedDescription)"
        }
        isLoading = false
    }
}

private struct TotalOwedCard: View {
    let total: String
    let score: Int?
    let category: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Total debiendo")
                .font(.poppins(14, .medium))
                .foregroundStyle(.white.opacity(0.85))

            Text("S/ \(total)")
                .font(.poppins(36, .bold))
                .foregroundStyle(.white)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Label("Score crediticio", systemImage: "chart.line.uptrend.xyaxis")
                        .font(.poppins(13, .medium))
                    Spacer()
                    StatusBadge(
                        text: category,
                        icon: (score ?? 0) >= 90 ? "sparkles" : (score == nil ? "clock" : "exclamationmark.triangle.fill"),
                        foreground: (score ?? 100) < 50 ? .fiDanger : .fiTealDark,
                        background: .white
                    )
                }
                .foregroundStyle(.white)

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(score.map(String.init) ?? "—")
                        .font(.poppins(24, .semibold))
                    Text("/100")
                        .font(.poppins(13))
                        .opacity(0.8)
                }
                .foregroundStyle(.white)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(.white.opacity(0.25))
                        Capsule()
                            .fill((score ?? 0) >= 75 ? Color.fiGold : ((score ?? 0) >= 50 ? Color.orange : Color.fiDanger))
                            .frame(width: geo.size.width * Double(min(max(score ?? 0, 0), 100)) / 100.0)
                    }
                }
                .frame(height: 6)
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 14).fill(.white.opacity(0.14)))
            .padding(.top, 16)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(colors: [.fiTeal, .fiTealDark], startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: Color.fiTealDark.opacity(0.3), radius: 14, y: 8)
        )
    }
}

#Preview {
    HomeView()
        .environment(AppRouter())
        .environment(ProfileStore())
}
