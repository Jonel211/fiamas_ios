import SwiftUI

struct MainTabBar: View {
    @Binding var selected: MainTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.allCases, id: \.self) { item in
                let isSelected = selected == item
                Button {
                    selected = item
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: isSelected ? item.selectedIcon : item.icon)
                            .font(.system(size: 21, weight: isSelected ? .semibold : .regular))
                            .frame(height: 26)
                        Text(item.title)
                            .font(.poppins(12, isSelected ? .semibold : .medium))
                    }
                    .foregroundStyle(isSelected ? Color.fiTeal : Color.fiTextTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(.horizontal, 8)
        .background(
            Color.white
                .shadow(color: .black.opacity(0.06), radius: 8, y: -2)
                .ignoresSafeArea(edges: .bottom)
        )
        .sensoryFeedback(.selection, trigger: selected)
    }
}
