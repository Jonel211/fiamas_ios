import SwiftUI

struct AboutView: View {
    @Environment(AppRouter.self) private var router

    private let features: [(icon: String, title: String)] = [
        ("list.bullet.rectangle", "Ver mis fiados"),
        ("banknote", "Historial de pagos"),
        ("creditcard", "Consultar mi límite"),
        ("chart.line.uptrend.xyaxis", "Ver mi score"),
    ]

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        VStack(spacing: 0) {
            FiHeader(title: "Acerca de Fiamas", leading: .back, trailingIcon: nil, onLeading: { router.pop() })

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    brand
                        .padding(.bottom, 28)

                    SectionHeader(title: "Quiénes somos")
                        .padding(.bottom, 8)

                    Text("Fiamas te permite ver tus fiados y pagos en cada tienda de forma clara y transparente.")
                        .font(.poppins(14))
                        .foregroundStyle(Color.fiTextSecondary)
                        .lineSpacing(3)
                        .fiCard()
                        .padding(.bottom, 28)

                    SectionHeader(title: "Qué puedes hacer")
                        .padding(.bottom, 12)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(features.indices, id: \.self) { index in
                            featureCard(features[index])
                        }
                    }
                    .padding(.bottom, 28)

                    Text("© 2026 Fiamas")
                        .font(.poppins(12))
                        .foregroundStyle(Color.fiTextTertiary)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 24)
            }
        }
        .fiScreenBackground()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var brand: some View {
        VStack(spacing: 8) {
            FiamasLogo(layout: .vertical, iconHeight: 64)
            Text("Digitalizando la confianza")
                .font(.poppins(14))
                .foregroundStyle(Color.fiTextSecondary)
            Text(AppVersion.display)
                .font(.poppins(12))
                .foregroundStyle(Color.fiTextTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
        )
    }

    private func featureCard(_ feature: (icon: String, title: String)) -> some View {
        VStack(alignment: .center, spacing: 10) {
            IconTile(systemName: feature.icon, size: 40)
            Text(feature.title)
                .font(.poppins(14, .semibold))
                .foregroundStyle(Color.fiTextPrimary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, minHeight: 110)
        .fiCard()
    }
}

#Preview {
    AboutView().environment(AppRouter())
}
