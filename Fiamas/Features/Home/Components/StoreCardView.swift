import SwiftUI

struct StoreCardView: View {
    let store: Store

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                
                // --- NUEVO: Foto de la tienda ---
                if let imagenUrl = store.imagenUrl, let url = URL(string: imagenUrl) {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 44, height: 44)
                                .clipShape(Circle())
                        } else if phase.error != nil {
                            IconTile(systemName: "storefront", size: 44) // Si la URL falla
                        } else {
                            ProgressView()
                                .frame(width: 44, height: 44) // Mientras carga
                        }
                    }
                } else {
                    // Si no hay foto en la BD, mostramos el icono por defecto
                    IconTile(systemName: "storefront", size: 44)
                }
                // ---------------------------------

                VStack(alignment: .leading, spacing: 2) {
                    Text(store.name)
                        .font(.poppins(16, .semibold))
                        .foregroundStyle(Color.fiTextPrimary)
                    Text(store.description)
                        .font(.poppins(13))
                        .foregroundStyle(Color.fiTextSecondary)
                }
                Spacer(minLength: 0)
                Text(store.date)
                    .font(.poppins(12))
                    .foregroundStyle(Color.fiTextTertiary)
            }

            CreditUsageBar(used: store.used, limit: store.limit)
        }
        .fiCard()
    }
}
