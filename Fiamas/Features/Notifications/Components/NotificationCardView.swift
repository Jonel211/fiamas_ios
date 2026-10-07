import SwiftUI

struct NotificationCardView: View {
    let item: AppNotification

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: item.kind.icon)
                .font(.system(size: 17))
                .foregroundStyle(Color.fiTeal)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(item.title)
                        .font(.inter(14, item.unread ? .semibold : .regular))
                        .foregroundStyle(Color.fiTextPrimary)
                    Spacer(minLength: 8)
                    Text(item.time)
                        .font(.inter(11))
                        .foregroundStyle(Color.fiLightGrayText)
                }
                Text(item.message)
                    .font(.inter(12))
                    .foregroundStyle(Color.fiGrayText)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Circle()
                .fill(item.unread ? Color.fiTeal : .clear)
                .frame(width: 8, height: 8)
                .padding(.top, 5)
        }
        .padding(.vertical, 14)
    }
}
