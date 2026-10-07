import SwiftUI

/// iOS-fiados
struct CreditsView: View {
    @Environment(AppRouter.self) private var router
    /// Tiendas abiertas; se pueden abrir varias a la vez.
    @State private var expanded: Set<String> = ["Tienda - Juancito"]

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
                    ForEach(Store.samples) { store in
                        StoreCreditsSectionView(
                            store: store,
                            credits: Credit.samples[store.name] ?? [],
                            isExpanded: expanded.contains(store.name)
                        ) {
                            withAnimation(.spring(duration: 0.3)) {
                                if expanded.contains(store.name) {
                                    expanded.remove(store.name)
                                } else {
                                    expanded.insert(store.name)
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
    }
}

#Preview {
    CreditsView().environment(AppRouter())
}
