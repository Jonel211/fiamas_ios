import SwiftUI

struct PaymentRowView: View {
    let payment: Payment

    var body: some View {
        HStack(spacing: 12) {
            IconTile(systemName: "banknote", size: 40, isCircle: true)

            VStack(alignment: .leading, spacing: 2) {
                Text(payment.store)
                    .font(.poppins(15, .semibold))
                    .foregroundStyle(Color.fiTextPrimary)
                Text(payment.concept)
                    .font(.poppins(13))
                    .foregroundStyle(Color.fiTextSecondary)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 2) {
                Text(payment.amount)
                    .font(.poppins(15, .semibold))
                    .foregroundStyle(Color.fiTeal)
                Text("\(payment.time) · \(payment.method)")
                    .font(.poppins(12))
                    .foregroundStyle(Color.fiTextTertiary)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.fiTextTertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}
