import SwiftUI

/// Un fiado dentro de la tarjeta de su tienda.
struct CreditCardView: View {
    let credit: Credit

    private var footnoteColor: Color {
        credit.status == .overdue ? .fiDanger : .fiTextSecondary
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center) {
                Text(credit.amount)
                    .font(.poppins(20, .semibold))
                    .foregroundStyle(Color.fiTextPrimary)
                Spacer()
                switch credit.status {
                case .overdue: StatusBadge.overdue
                case .pending: StatusBadge.pending
                }
            }

            Text(credit.items)
                .font(.poppins(14))
                .foregroundStyle(Color.fiTextSecondary)
                .lineLimit(2)

            HStack {
                Label(credit.date, systemImage: "calendar")
                    .foregroundStyle(Color.fiTextTertiary)
                Spacer()
                Text(credit.footnote)
                    .font(.poppins(12, .medium))
                    .foregroundStyle(footnoteColor)
            }
            .font(.poppins(12))
            .padding(.top, 2)
        }
        .padding(.vertical, 14)
    }
}
