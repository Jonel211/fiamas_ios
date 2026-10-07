import SwiftUI

struct StoreCardView: View {
    let store: Store

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                IconTile(systemName: "storefront", size: 44)
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
