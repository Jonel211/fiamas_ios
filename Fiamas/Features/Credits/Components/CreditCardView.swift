import SwiftUI

/// Un fiado dentro de la tarjeta de su tienda.
struct CreditCardView: View {
    let credit: Credit
    var showChevron: Bool = false

    private var footnoteColor: Color {
        credit.status == .overdue ? .fiDanger : .fiTextSecondary
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center, spacing: 8) {
                Text(credit.amount)
                    .font(.poppins(20, .semibold))
                    .foregroundStyle(Color.fiTextPrimary)
                Spacer()
                switch credit.status {
                case .overdue: StatusBadge.overdue
                case .pending: StatusBadge.pending
                case .partial: StatusBadge(text: "Pago parcial", foreground: .fiWarning, background: .fiWarningSoft)
                case .paid: StatusBadge(text: "Pagado")
                case .cancelled: StatusBadge(text: "Cancelado", foreground: .fiTextSecondary, background: .fiDivider)
                }
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.fiTextTertiary)
                }
            }

            Text(credit.items)
                .font(.poppins(14))
                .foregroundStyle(Color.fiTextSecondary)
                .lineLimit(2)

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    if let createdAt = credit.createdAt, !createdAt.isEmpty {
                        Label(createdAt, systemImage: "clock")
                            .foregroundStyle(Color.fiTextTertiary)
                    }
                    if !credit.date.isEmpty {
                        Label(credit.date, systemImage: "calendar")
                            .foregroundStyle(Color.fiTextTertiary)
                    }
                }
                Spacer()
                Text(credit.footnote)
                    .font(.poppins(12, .medium))
                    .foregroundStyle(footnoteColor)
            }
            .font(.poppins(12))
            .padding(.top, 2)
        }
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}
