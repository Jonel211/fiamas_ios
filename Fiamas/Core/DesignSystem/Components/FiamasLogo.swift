import SwiftUI

struct FiamasLogo: View {
    enum Layout { case iconOnly, horizontal, vertical }
    var layout: Layout = .vertical
    var iconHeight: CGFloat = 60

    var body: some View {
        switch layout {
        case .iconOnly:
            icon
        case .horizontal:
            HStack(spacing: 8) {
                icon
                wordmark(size: iconHeight * 0.45)
            }
        case .vertical:
            VStack(spacing: 4) {
                icon
                wordmark(size: iconHeight * 0.42)
            }
        }
    }

    private var icon: some View {
        Image("Logo")
            .resizable()
            .scaledToFit()
            .frame(height: iconHeight)
    }

    private func wordmark(size: CGFloat) -> some View {
        Text("FIAMAS")
            .font(.system(size: size, weight: .bold))
            .tracking(1)
            .foregroundStyle(Color.fiNavy)
    }
}
