import SwiftUI

/// Barra superior verde de las pantallas internas.
struct FiHeader: View {
    enum Leading { case menu, back }

    let title: String
    var leading: Leading = .menu
    var trailingIcon: String? = "bell"
    var trailingLabel: String = "Notificaciones"
    var trailingBadge: Bool = false
    var secondaryTrailingIcon: String? = nil
    var secondaryTrailingLabel: String = ""
    var onLeading: () -> Void = {}
    var onTrailing: () -> Void = {}
    var onSecondaryTrailing: () -> Void = {}

    var body: some View {
        HStack(spacing: 0) {
            iconButton(
                leading == .menu ? "line.3.horizontal" : "chevron.left",
                label: leading == .menu ? "Menú" : "Atrás",
                action: onLeading
            )

            Spacer()

            HStack(spacing: 0) {
                if let secondaryTrailingIcon {
                    iconButton(
                        secondaryTrailingIcon,
                        label: secondaryTrailingLabel.isEmpty ? secondaryTrailingIcon : secondaryTrailingLabel,
                        action: onSecondaryTrailing
                    )
                }

                if let trailingIcon {
                    iconButton(trailingIcon, label: trailingLabel, action: onTrailing)
                        .overlay(alignment: .topTrailing) {
                            if trailingBadge {
                                Circle()
                                    .fill(Color.fiGold)
                                    .frame(width: 9, height: 9)
                                    .overlay(Circle().stroke(Color.fiTeal, lineWidth: 2))
                                    .offset(x: -9, y: 10)
                            }
                        }
                } else if secondaryTrailingIcon == nil {
                    Color.clear.frame(width: 44, height: 44)
                }
            }
        }
        .overlay {
            Text(title)
                .font(.poppins(18, .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .padding(.horizontal, secondaryTrailingIcon != nil ? 96 : 56)
        }
        .padding(.horizontal, 8)
        .frame(height: 44)
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
        .background(Color.fiTeal.ignoresSafeArea(edges: .top))
        .toolbarBackground(Color.fiTeal, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .preferredColorScheme(.dark)
    }

    private func iconButton(_ systemName: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}
