import SwiftUI

struct StoreCreditsSectionView: View {
    let store: Store
    let credits: [Credit]
    let isExpanded: Bool
    let toggle: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .top) {
                VStack(spacing: 4) {
                    Text(store.name)
                        .font(.inter(16, .semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if isExpanded {
                        CreditProgressView(used: store.used, limit: store.limit, width: 125, compact: true)
                    }
                }
                Button(action: toggle) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: isExpanded ? 18 : 15, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: isExpanded ? 38 : 30, height: isExpanded ? 28 : 26)
                        .background(RoundedRectangle(cornerRadius: 6).fill(Color.fiTeal))
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 8)
            .padding(.bottom, isExpanded ? 0 : 8)

            if isExpanded {
                VStack(spacing: 10) {
                    if credits.isEmpty {
                        Text("No tienes fiados en esta tienda")
                            .font(.inter(11))
                            .foregroundStyle(Color.fiGrayText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    ForEach(credits) { credit in
                        CreditCardView(credit: credit)
                    }
                }
                .padding(.horizontal, 6)
                .padding(.bottom, 8)
            }
        }
        .cardStyle(cornerRadius: 6, border: .fiCardBorder, fill: .fiSectionBackground)
    }
}
