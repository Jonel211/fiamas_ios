import SwiftUI

struct MenuRowView: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(Color.fiTeal)
                .frame(width: 22)
            Text(title)
                .font(.poppins(15))
                .foregroundStyle(.black)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.fiChevron)
        }
        .frame(height: 56)
        .contentShape(Rectangle())
    }
}
