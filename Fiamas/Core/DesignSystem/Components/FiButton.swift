import SwiftUI

struct FiButton: View {
    let title: String
    var color: Color = .fiTeal
    var font: Font = .inter(15, .semibold)
    var height: CGFloat = 34
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(font)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .background(RoundedRectangle(cornerRadius: 6).fill(color))
        }
        .buttonStyle(.plain)
    }
}
