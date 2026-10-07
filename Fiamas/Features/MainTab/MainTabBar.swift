import SwiftUI

struct MainTabBar: View {
    @Binding var selected: MainTab

    var body: some View {
        HStack {
            ForEach(MainTab.allCases, id: \.self) { item in
                Button {
                    selected = item
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: item.icon)
                            .font(.system(size: 22, weight: .light))
                            .foregroundStyle(.black)
                            .frame(height: 26)
                        Text(item.title)
                            .font(.poppins(11, selected == item ? .semibold : .medium))
                            .foregroundStyle(selected == item ? Color.fiTeal : .black)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 10)
        .padding(.bottom, 4)
        .background(Color.white)
    }
}
