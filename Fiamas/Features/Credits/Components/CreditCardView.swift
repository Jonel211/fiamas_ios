import SwiftUI

struct CreditCardView: View {
    let credit: Credit

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(credit.amount)
                    .font(.inter(18, .semibold))
                    .foregroundStyle(Color.fiTextPrimary)
                Spacer()
                switch credit.status {
                case .overdue:
                    StatusBadge(text: "VENCIDO", foreground: .fiRed, background: .fiRedSoft)
                case .pending:
                    StatusBadge(text: "PENDIENTE", foreground: .fiOrange, background: .fiOrangeSoft)
                }
            }
            Text(credit.items)
                .font(.inter(11))
                .foregroundStyle(Color.fiGrayText)
                .lineLimit(2)
            HStack {
                Text(credit.date)
                    .font(.inter(10))
                    .foregroundStyle(Color.fiLightGrayText)
                Spacer()
                Text(credit.footnote)
                    .font(.inter(10, .medium))
                    .foregroundStyle(Color.fiOrange)
            }
        }
        .padding(12)
        .cardStyle(cornerRadius: 10, border: Color.fiNeutralBorder, shadow: true)
    }
}
