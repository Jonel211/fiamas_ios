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
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.black.opacity(0.06), lineWidth: 1)
                                        )
                                        .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
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
        .background(Color(red: 0.92, green: 0.94, blue: 0.94).ignoresSafeArea())
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

// MARK: - Card principal

private struct TotalOwedCard: View {
    let total: String
    let score: Int?
    let category: String

   
    private let rightTop   = Color(red: 0.19, green: 0.55, blue: 0.52)
    private let rightBot   = Color(red: 0.15, green: 0.46, blue: 0.44)

    private let swatchTeal = Color(red: 0.19, green: 0.55, blue: 0.52)
    private let mintTop    = Color(red: 0.80, green: 0.92, blue: 0.88)
    private let mintMid    = Color(red: 0.55, green: 0.78, blue: 0.73)

    var body: some View {
        ZStack {
            
            LinearGradient(colors: [rightTop, rightBot],
                           startPoint: .topLeading, endPoint: .bottomTrailing)

        
            LeftPanelShape()
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: mintTop,    location: 0.0),
                            .init(color: mintMid,    location: 0.5),
                            .init(color: swatchTeal, location: 1.0)
                        ],
                        startPoint: .top, endPoint: .bottom)
                )
                .overlay(
                    
                    LeftPanelShape()
                        .stroke(.white.opacity(0.18), lineWidth: 1)
                )

            VStack(spacing: 12) {
                HStack(spacing: 0) {
                    StoreIllustration()
                        .scaleEffect(1.12)
                        .frame(width: 140, height: 115)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Total debiendo")
                            .font(.poppins(18, .medium))
                            .foregroundStyle(.white.opacity(0.92))
                        Text("S/ \(total)")
                            .font(.poppins(34, .bold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 35)
                }

                // Píldora del score: translúcida, más clara a la izquierda
                HStack(spacing: 12) {
                    Label("Score crediticio", systemImage: "chart.bar.fill")
                        .font(.poppins(12, .medium))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Spacer(minLength: 4)

                    Rectangle()
                        .fill(.white.opacity(0.35))
                        .frame(width: 1, height: 22)

                    StatusBadge(
                        text: category,
                        icon: (score ?? 0) >= 90 ? "sparkles" : (score == nil ? "clock" : "exclamationmark.triangle.fill"),
                        foreground: (score ?? 100) < 50 ? .fiDanger : .fiTealDark,
                        background: .white
                    )
                    .fixedSize(horizontal: true, vertical: false)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(LinearGradient(colors: [.white.opacity(0.24), .white.opacity(0.07)],
                                             startPoint: .leading, endPoint: .trailing))
                )
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
    }
}

// MARK: - Curva del panel izquierdo

// Arranca arriba en ~51% y baja hacia la izquierda hasta ~29%
private struct LeftPanelShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        p.move(to: CGPoint(x: 0, y: 0))
        p.addLine(to: CGPoint(x: w * 0.51, y: 0))
        p.addCurve(to: CGPoint(x: w * 0.29, y: h),
                   control1: CGPoint(x: w * 0.47, y: h * 0.25),
                   control2: CGPoint(x: w * 0.38, y: h * 0.62))
        p.addLine(to: CGPoint(x: 0, y: h))
        p.closeSubpath()
        return p
    }
}

// MARK: - Tiendita a color

private struct StoreIllustration: View {
    private let green  = Color(red: 0.13, green: 0.50, blue: 0.36)
    private let cream  = Color(red: 0.99, green: 0.96, blue: 0.88)
    private let yellow = Color(red: 0.98, green: 0.76, blue: 0.25)

    var body: some View {
        ZStack(alignment: .bottom) {
            // Base
            Ellipse()
                .fill(Color(red: 0.55, green: 0.80, blue: 0.70))
                .frame(width: 124, height: 22)
                .offset(y: 4)

            // Hojas
            Image(systemName: "leaf.fill")
                .font(.system(size: 30))
                .foregroundStyle(Color(red: 0.36, green: 0.68, blue: 0.40))
                .rotationEffect(.degrees(-35))
                .offset(x: -48, y: -14)

            // Tienda
            VStack(spacing: 0) {
                Capsule().fill(green).frame(width: 74, height: 8)          // techo

                HStack(spacing: 0) {                                        // toldo
                    ForEach(0..<6, id: \.self) { i in
                        Rectangle().fill(i % 2 == 0 ? green : Color.white)
                    }
                }
                .frame(width: 92, height: 22)
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 3, bottomLeadingRadius: 9,
                                                  bottomTrailingRadius: 9, topTrailingRadius: 3))

                ZStack {                                                    // cuerpo
                    Rectangle().fill(cream)
                    HStack(spacing: 10) {
                        RoundedRectangle(cornerRadius: 3).fill(green)       // puerta
                            .frame(width: 18, height: 34)
                        RoundedRectangle(cornerRadius: 3).fill(yellow)      // ventana
                            .frame(width: 26, height: 20)
                            .offset(y: -4)
                    }
                }
                .frame(width: 80, height: 40)
            }
            .offset(y: -6)
        }
    }
}

#Preview {
    HomeView()
        .environment(AppRouter())
        .environment(ProfileStore())
}
