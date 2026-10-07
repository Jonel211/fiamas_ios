import SwiftUI

struct StoreCardView: View {
    let store: Store

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(store.name)
                .font(.inter(16, .semibold))
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(store.description)
                        .font(.inter(11))
                        .foregroundStyle(Color.fiGrayText)
                    Text(store.date)
                        .font(.inter(10))
                        .foregroundStyle(Color.fiLightGrayText)
                }
                Spacer()
                CreditProgressView(used: store.used, limit: store.limit)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .cardStyle(cornerRadius: 10, border: Color.fiNeutralBorder, shadow: true)
    }
}
