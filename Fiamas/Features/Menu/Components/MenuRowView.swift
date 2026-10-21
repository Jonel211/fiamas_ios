import SwiftUI

struct MenuRowView: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 14) {
            IconTile(systemName: icon, size: 36)
            Text(title)
                .font(.poppins(15, .medium))
                .foregroundStyle(Color.fiTextPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.fiTextTertiary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}
