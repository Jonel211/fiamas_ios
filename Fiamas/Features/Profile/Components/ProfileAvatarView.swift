import SwiftUI

/// Foto de perfil circular; si no hay foto muestra las iniciales.
struct ProfileAvatarView: View {
    let photo: UIImage?
    let initials: String
    var size: CGFloat = 74
    var showsCameraBadge = true

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if let photo {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                } else {
                    LinearGradient(colors: [.fiTeal, .fiTealDark], startPoint: .topLeading, endPoint: .bottomTrailing)
                        .overlay(
                            Text(initials)
                                .font(.poppins(size * 0.34, .semibold))
                                .foregroundStyle(.white)
                        )
                }
            }
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(Circle().stroke(.white, lineWidth: 4))
            .shadow(color: .black.opacity(0.1), radius: 8, y: 4)

            if showsCameraBadge {
                Image(systemName: "camera.fill")
                    .font(.system(size: size * 0.13, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: size * 0.32, height: size * 0.32)
                    .background(Circle().fill(Color.fiGold))
                    .overlay(Circle().stroke(.white, lineWidth: 2.5))
                    .offset(x: 2, y: 2)
            }
        }
    }
}
