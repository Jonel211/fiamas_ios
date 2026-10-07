import SwiftUI

struct NotificationCardView: View {
    let item: AppNotification

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Circle()
                    .fill(item.kind.background)
                    .frame(width: 26, height: 26)
                    .overlay(
                        Image(systemName: item.kind.icon)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(item.kind.foreground)
                    )
                StatusBadge(text: item.kind.label, foreground: item.kind.foreground,
                            background: item.kind.background, font: .inter(8, .medium))
                Spacer()
                Text(item.time)
                    .font(.inter(9))
                    .foregroundStyle(Color.fiLightGrayText)
            }
            .overlay(alignment: .topTrailing) {
                if item.unread {
                    Circle().fill(Color.fiTealDark).frame(width: 5, height: 5).offset(y: -6)
                }
            }

            Text(item.title)
                .font(.inter(13, .medium))
            Text(item.message)
                .font(.inter(9))
                .foregroundStyle(Color.fiTextBody)
                .lineSpacing(3)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 8).fill(.white))
    }
}
