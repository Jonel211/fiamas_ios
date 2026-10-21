import SwiftUI

/// iOS-inicio
struct HomeView: View {
    @Environment(AppRouter.self) private var router
    @Environment(ProfileStore.self) private var profileStore

    // ESTADOS PARA LA CONEXIÓN CON EL SERVIDOR
    @State private var fiadosAPI: [FiadoAPI] = []
    @State private var isLoading = true
    
    // Ya no mostraremos el error crudo, solo mostraremos la lista vacía
    // @State private var errorMessage: String? = nil

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
                        // Siempre mostramos la tarjeta, si hay error el total es 0.00
                        TotalOwedCard(total: totalOwed, score: 92)
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
        }
        .fiScreenBackground()
        .task {
            await loadData()
        }
    }
    
    private func loadData() async {
        isLoading = true
        do {
            fiadosAPI = try await DebtsService.shared.fetchMyDebts()
        } catch {
            print("Error al cargar fiados: \(error.localizedDescription)")
            fiadosAPI = []
        }
        isLoading = false
    }
}

// ... (Deja la struct TotalOwedCard exactamente igual que antes)
private struct TotalOwedCard: View {
    let total: String
    let score: Int

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
                    StatusBadge(text: "Pagador bueno", icon: "hand.thumbsup.fill",
                                foreground: .fiTealDark, background: .white)
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
                        Capsule().fill(Color.fiGold).frame(width: geo.size.width * Double(score) / 100)
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
