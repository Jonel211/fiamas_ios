import SwiftUI

struct StepIndicator: View {
    /// Paso actual (1, 2 o 3)
    let current: Int

    var body: some View {
        HStack(spacing: 4) {
            step(1)
            connector(arrow: true)
            step(2)
            connector(arrow: current >= 2)
            step(3)
        }
    }

    private func step(_ number: Int) -> some View {
        let active = number <= current
        return Text("\(number)")
            .font(.inter(14, .semibold))
            .foregroundStyle(active ? .white : Color.fiLightGrayText)
            .frame(width: 20, height: 24)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(active ? Color.fiGold : .white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(active ? Color.clear : Color.fiFieldBorder, lineWidth: 1)
            )
    }

    private func connector(arrow: Bool) -> some View {
        HStack(spacing: 0) {
            Rectangle().fill(.black).frame(width: arrow ? 22 : 26, height: 1)
            if arrow {
                Image(systemName: "chevron.right")
                    .font(.system(size: 7, weight: .semibold))
                    .padding(.leading, -4)
            }
        }
        .frame(width: 28)
    }
}
