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
                onLeading: { router.push(.menu) },
                onTrailing: { router.push(.notifications) }
            )

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(Store.samples) { store in
                        StoreCreditsSectionView(
                            store: store,
                            credits: Credit.samples[store.name] ?? [],
                            isExpanded: expanded.contains(store.name)
                        ) {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                if expanded.contains(store.name) {
                                    expanded.remove(store.name)
                                } else {
                                    expanded.insert(store.name)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 24)
                .padding(.bottom, 16)
            }
        }
    }
}

#Preview {
    CreditsView().environment(AppRouter())
}
