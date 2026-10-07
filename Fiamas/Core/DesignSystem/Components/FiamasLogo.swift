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
            HStack(spacing: 10) {
                icon
                wordmark(size: iconHeight * 0.5)
            }
        case .vertical:
            VStack(spacing: 6) {
                icon
                wordmark(size: iconHeight * 0.4)
            }
        }
    }

    private var icon: some View {
        Image("Logo")
            .resizable()
            .scaledToFit()
            .frame(height: iconHeight)
            .accessibilityHidden(true)
    }

    private func wordmark(size: CGFloat) -> some View {
        Text("FIAMAS")
            .font(.poppins(size, .bold))
            .tracking(1.5)
            .foregroundStyle(Color.fiNavy)
    }
}
