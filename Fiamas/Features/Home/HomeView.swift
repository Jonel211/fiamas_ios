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
    @State private var refreshBannerMessage: String?
    @State private var isLoading = true
    @State private var hasLoadedOnce = false
    @State private var isShowingScanner = false

    private var mappedStores: [Store] {
        storeSummaries.map { summary in
            let fiados = fiadosAPI.filter { $0.tienda?.id == summary.tienda.id }
            return Store(
                id: summary.tienda.id,
                name: summary.tienda.nombre,
                description: "\(fiados.count) fiados registrados",
                date: fiados.first.map { String($0.fechaCreacion.prefix(10)) } ?? "",
                used: summary.saldoActual,
                limit: summary.limiteCredito,
                imagenUrl: summary.tienda.imagenUrl
            )
        }
        .sorted { $0.name < $1.name }
    }

    var body: some View {
        VStack(spacing: 0) {
            FiHeader(
                title: "Bienvenido",
                trailingBadge: fiadosAPI.contains { $0.daysUntilDue.map { $0 <= 2 } ?? false },
                secondaryTrailingIcon: "qrcode.viewfinder",
                secondaryTrailingLabel: "Vincular tienda por QR",
                onLeading: { router.push(.menu) },
                onTrailing: { router.push(.notifications) },
                onSecondaryTrailing: { isShowingScanner = true }
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

                    Text("Hola, \(profileStore.profile.firstName)")
                        .font(.poppins(22, .semibold))
                        .foregroundStyle(Color.fiTextPrimary)
                    Text("Este es el resumen de tus fiados")
                        .font(.poppins(14))
                        .foregroundStyle(Color.fiTextSecondary)
                        .padding(.bottom, 16)

                    if isLoading && !hasLoadedOnce {
                        ProgressView("Cargando...")
                            .frame(maxWidth: .infinity)
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
                                Task { await loadData() }
                            }
                            .font(.poppins(14, .semibold))
                            .foregroundStyle(Color.fiTeal)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        TotalOwedCard(total: String(format: "%.2f", totalOwed), score: clientScore, category: clientCategory)
                            .padding(.bottom, 28)

                        SectionHeader(title: "Tiendas vinculadas", trailing: "\(mappedStores.count) tiendas")
                            .padding(.bottom, 12)

                        if mappedStores.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "cart.badge.questionmark")
                                    .font(.system(size: 40))
                                    .foregroundStyle(Color.fiTextTertiary)
                                Text("Aún no tienes tiendas vinculadas.")
                                    .font(.poppins(14, .medium))
                                    .foregroundStyle(Color.fiTextSecondary)

                                Button {
                                    isShowingScanner = true
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "qrcode.viewfinder")
                                        Text("Escanear QR de Tienda")
                                    }
                                    .font(.poppins(13, .semibold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Capsule().fill(Color.fiTeal))
                                }
                                .buttonStyle(.plain)
                                .padding(.top, 4)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                            .fiCard()
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
        .fullScreenCover(isPresented: $isShowingScanner) {
            LinkStoreScannerSheet { _ in
                Task {
                    await loadData()
                }
            }
        }
        .task {
            await loadData()
        }
    }

    private func loadData() async {
        if !hasLoadedOnce { isLoading = true }
        errorMessage = nil
        refreshBannerMessage = nil

        async let debtsTask = DebtsService.shared.fetchMyDebts()
        async let summaryTask = SummaryService.shared.fetchMySummary()

        do {
            let (debts, summary) = try await (debtsTask, summaryTask)
            fiadosAPI = debts
            storeSummaries = summary.stores
            totalOwed = summary.totalOwed
            clientScore = summary.score
            clientCategory = summary.category
            profileStore.updateScoring(score: clientScore, category: clientCategory)
            await ReminderScheduler.sync(fiadosAPI)
            hasLoadedOnce = true
        } catch is CancellationError {
            return
        } catch {
            if !hasLoadedOnce {
                errorMessage = "No se pudo cargar tu resumen: \(error.localizedDescription)"
            } else {
                refreshBannerMessage = "No se pudo actualizar. Mostrando últimos datos guardados."
            }
        }
        isLoading = false
    }
}

// MARK: - Card principal

private struct TotalOwedCard: View {
    let total: String
    let score: Int?
    let category: String

    // Lado Derecho (Verde)
    private let rightTop = Color(red: 0.19, green: 0.55, blue: 0.52)
    private let rightBot = Color(red: 0.15, green: 0.46, blue: 0.44)

    // Lado Izquierdo (Puro Naranja)
    private let orangeTop = Color(red: 245/255, green: 205/255, blue: 120/255)
    private let orangeMid = Color.fiOrange // #E0AA3D
    private let orangeBot = Color(red: 190/255, green: 130/255, blue: 30/255)

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [rightTop, rightBot],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            LeftPanelShape()
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: orangeTop, location: 0.0),
                            .init(color: orangeMid, location: 0.5),
                            .init(color: orangeBot, location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    LeftPanelShape()
                        .stroke(.white.opacity(0.18), lineWidth: 1)
                )

            VStack(spacing: 12) {
                HStack(spacing: 0) {
                    // Imagen ajustada
                    Image("card-tiendas")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 130, height: 115)
                        .scaleEffect(1.30)
                        .offset(x: 10, y: 0)
                    
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

                // Píldora del score
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

                    // --- CAMBIO: Texto negro en el Badge Naranja ---
                    StatusBadge(
                        text: category,
                        icon: (score ?? 0) >= 90 ? "sparkles" : (score == nil ? "clock" : "exclamationmark.triangle.fill"),
                        foreground: .black, // <-- Texto negro
                        background: .fiOrange // Fondo naranja
                    )
                    .fixedSize(horizontal: true, vertical: false)
                    // ------------------------------------------------
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.24), .white.opacity(0.07)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
    }
}

// MARK: - Curva del panel izquierdo

private struct LeftPanelShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        p.move(to: CGPoint(x: 0, y: 0))
        p.addLine(to: CGPoint(x: w * 0.51, y: 0))
        p.addCurve(
            to: CGPoint(x: w * 0.29, y: h),
            control1: CGPoint(x: w * 0.47, y: h * 0.25),
            control2: CGPoint(x: w * 0.38, y: h * 0.62)
        )
        p.addLine(to: CGPoint(x: 0, y: h))
        p.closeSubpath()
        return p
    }
}

#Preview {
    HomeView()
        .environment(AppRouter())
        .environment(ProfileStore())
}
