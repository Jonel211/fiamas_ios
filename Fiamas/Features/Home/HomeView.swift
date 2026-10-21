import SwiftUI

/// iOS-inicio
struct HomeView: View {
    @Environment(AppRouter.self) private var router
    @Environment(ProfileStore.self) private var profileStore

    private let stores = Store.samples

    private var totalOwed: Int { stores.map(\.used).reduce(0, +) }

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

                    TotalOwedCard(total: totalOwed, score: 92)
                        .padding(.bottom, 28)

                    SectionHeader(title: "Tiendas recientes", trailing: "\(stores.count) tiendas")
                        .padding(.bottom, 12)

                    VStack(spacing: 12) {
                        ForEach(stores) { store in
                            StoreCardView(store: store)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }
        }
        .fiScreenBackground()
    }
}

/// Tarjeta principal con el total adeudado y el score crediticio.
private struct TotalOwedCard: View {
    let total: Int
    let score: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Total debiendo")
                .font(.poppins(14, .medium))
                .foregroundStyle(.white.opacity(0.85))

            Text("S/ \(total).00")
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
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    HomeView()
        .environment(AppRouter())
        .environment(ProfileStore())
}
