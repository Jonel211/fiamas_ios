import SwiftUI

struct NotificationCardView: View {
    let item: AppNotification

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: item.kind.icon)
                .font(.system(size: 18))
                .foregroundStyle(Color.fiTeal)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(item.title)
                        .font(.poppins(15, item.unread ? .semibold : .regular))
                        .foregroundStyle(Color.fiTextPrimary)
                    Spacer(minLength: 8)
                    Text(item.time)
                        .font(.poppins(12))
                        .foregroundStyle(Color.fiTextTertiary)
                }
                Text(item.message)
                    .font(.poppins(13))
                    .foregroundStyle(Color.fiTextSecondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Circle()
                .fill(item.unread ? Color.fiTeal : .clear)
                .frame(width: 8, height: 8)
                .padding(.top, 7)
        }
        .padding(.vertical, 14)
        .accessibilityElement(children: .combine)
        .accessibilityHint(item.unread ? "Sin leer" : "")
    }
}
