import SwiftUI

struct PaymentRowView: View {
    let payment: Payment

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 10) {
                Text(payment.store)
                    .font(.poppins(13, .semibold))
                Text(payment.concept)
                    .font(.poppins(11))
                    .padding(.leading, 16)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 0) {
                Text(payment.amount).font(.poppins(11, .semibold))
                Text(payment.time).font(.poppins(11)).padding(.top, 2)
                Text(payment.method).font(.poppins(11))
            }
        }
        .foregroundStyle(.black)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .cardStyle(cornerRadius: 6, border: .fiCardBorder)
    }
}
