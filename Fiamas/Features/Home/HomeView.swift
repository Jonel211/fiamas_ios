import SwiftUI

/// iOS-inicio
struct HomeView: View {
    @Environment(AppRouter.self) private var router
    @Environment(ProfileStore.self) private var profileStore

    // Datos del servidor
    @State private var fiadosAPI: [FiadoAPI] = []
    @State private var clientScore: Int = 100
    @State private var clientCategory: String = "Excelente pagador"
    @State private var isLoading = true

    private var mappedStores: [Store] {
        var dict: [String: Store] = [:]
        for fiado in fiadosAPI {
            if let tienda = fiado.tienda {
                if let existing = dict[tienda.id] {
                    let newUsed = existing.used + Int(fiado.saldoPendiente)
                    dict[tienda.id] = Store(
                        name: existing.name,
                        description: existing.description,
                        date: existing.date,
                        used: newUsed,
                        limit: existing.limit
                    )
                } else {
                    dict[tienda.id] = Store(
                        name: tienda.nombre,
                        description: "Fiado pendiente",
                        date: String(fiado.fechaCreacion.prefix(10)),
                        used: Int(fiado.saldoPendiente),
                        limit: 1000
                    )
                }
            }
        }
        return Array(dict.values)
    }

    private var totalOwed: String {
        let total = fiadosAPI.map(\.saldoPendiente).reduce(0, +)
        return String(format: "%.2f", total)
    }

    var body: some View {
        VStack(spacing: 0) {
            FiHeader(
                title: "Bienvenido",
                trailingBadge: true,
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
                    } else {
                        TotalOwedCard(total: totalOwed, score: clientScore, category: clientCategory)
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
        async let debtsTask = DebtsService.shared.fetchMyDebts()
        async let summaryTask = SummaryService.shared.fetchMySummary()
        
        do {
            fiadosAPI = try await debtsTask
        } catch {
            print("Error al cargar fiados: \(error.localizedDescription)")
            fiadosAPI = []
        }
        
        do {
            let summary = try await summaryTask
            clientScore = summary.score
            clientCategory = Self.formatCategory(summary.category, score: summary.score)
        } catch {
            // Cálculo dinámico de respaldo según el estado real de fiados
            let hasOverdue = fiadosAPI.contains { $0.estado.lowercased() == "vencido" }
            if hasOverdue {
                clientScore = 60
                clientCategory = "Pagador regular"
            } else if !fiadosAPI.isEmpty {
                clientScore = 95
                clientCategory = "Pagador bueno"
            } else {
                clientScore = 100
                clientCategory = "Excelente pagador"
            }
        }
        
        profileStore.updateScoring(score: clientScore, category: clientCategory)
        isLoading = false
    }

    private static func formatCategory(_ rawCategory: String, score: Int) -> String {
        let cat = rawCategory.lowercased()
        if cat == "excelente" || score >= 90 { return "Excelente pagador" }
        if cat == "bueno" || score >= 75 { return "Pagador bueno" }
        if cat == "regular" || score >= 50 { return "Pagador regular" }
        if cat == "moroso" || score < 50 { return "En mora" }
        return "Nuevo cliente"
    }
}

private struct TotalOwedCard: View {
    let total: String
    let score: Int
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
                        icon: score >= 90 ? "sparkles" : (score >= 50 ? "hand.thumbsup.fill" : "exclamationmark.triangle.fill"),
                        foreground: score < 50 ? .fiDanger : .fiTealDark,
                        background: .white
                    )
                }
                .foregroundStyle(.white)

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(score)")
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
                            .fill(score >= 75 ? Color.fiGold : (score >= 50 ? Color.orange : Color.fiDanger))
                            .frame(width: geo.size.width * min(max(Double(score), 0.0), 100.0) / 100.0)
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
