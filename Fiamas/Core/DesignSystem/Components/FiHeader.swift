import SwiftUI

struct FiHeader: View {
    enum Leading { case menu, back }

    let title: String
    var leading: Leading = .menu
    var trailingIcon: String? = "bell"
    var color: Color = .fiTeal
    var onLeading: () -> Void = {}
    var onTrailing: () -> Void = {}

    var body: some View {
        ZStack {
            Text(title)
                .font(.inter(17, .semibold))
                .foregroundStyle(.white)

            HStack {
                Button(action: onLeading) {
                    switch leading {
                    case .menu:
                        VStack(spacing: 7) {
                            ForEach(0..<3, id: \.self) { _ in
                                Rectangle().fill(.white.opacity(0.9)).frame(width: 26, height: 1.5)
                            }
                        }
                    case .back:
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .frame(width: 44, height: 44)

                Spacer()

                if let trailingIcon {
                    Button(action: onTrailing) {
                        Image(systemName: trailingIcon)
                            .font(.system(size: 18, weight: .regular))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .background(color, ignoresSafeAreaEdges: [])
        // En el diseño la zona de la barra de estado es blanca
        .background(alignment: .top) {
            Color.white
                .frame(height: 0)
                .ignoresSafeArea(edges: .top)
        }
    }
}
