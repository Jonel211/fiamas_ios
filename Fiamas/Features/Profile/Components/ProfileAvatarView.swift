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
                    Color.fiTealDark
                        .overlay(
                            Text(initials)
                                .font(.inter(size * 0.36, .bold))
                                .foregroundStyle(.white)
                        )
                }
            }
            .frame(width: size, height: size)
            .clipShape(Circle())

            if showsCameraBadge {
                Circle()
                    .fill(.white)
                    .frame(width: size * 0.3, height: size * 0.3)
                    .overlay(
                        Image(systemName: "camera")
                            .font(.system(size: size * 0.13))
                            .foregroundStyle(Color.fiTealDark)
                    )
                    .shadow(color: .black.opacity(0.12), radius: 2, y: 1)
                    .offset(x: 2, y: 2)
            }
        }
    }
}
