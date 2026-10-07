import SwiftUI

/// iOS-inicio
struct HomeView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        VStack(spacing: 0) {
            FiHeader(
                title: "Bienvenido",
                onLeading: { router.push(.menu) },
                onTrailing: { router.push(.notifications) }
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    totalCard
                        .padding(.top, 18)

                    Text("Tiendas recientes")
                        .font(.poppins(16, .semibold))
                        .padding(.top, 18)
                        .padding(.bottom, 12)

                    VStack(spacing: 8) {
                        ForEach(Store.samples) { store in
                            StoreCardView(store: store)
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 16)
            }
        }
    }

    private var totalCard: some View {
        VStack(spacing: 10) {
            Text("Total debiendo")
                .font(.poppins(16, .bold))
                .foregroundStyle(.white)

            HStack(spacing: 16) {
                Text("S/.")
                    .foregroundStyle(.black)
                Text("8000")
                    .foregroundStyle(Color.fiTeal)
            }
            .font(.poppins(30, .medium))
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.fiTotalBox))
            .padding(.horizontal, 26)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Score crediticio")
                        .font(.poppins(7))
                    Spacer()
                    StatusBadge(text: "Pagador bueno", foreground: .fiTeal, background: .fiGreenSoft, font: .poppins(6))
                }
                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text("92").font(.poppins(18, .semibold))
                    Text("/100").font(.poppins(7))
                }
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.fiSky)
                    GeometryReader { geo in
                        Capsule().fill(Color.fiTealDark).frame(width: geo.size.width * 0.92)
                    }
                }
                .frame(height: 4)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 10).fill(.white))
            .padding(.horizontal, 26)
        }
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(Color.fiTeal)
    }
}

#Preview {
    HomeView().environment(AppRouter())
}
