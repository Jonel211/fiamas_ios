import SwiftUI

/// iOS-notification
struct NotificationsView: View {
    @Environment(AppRouter.self) private var router

    @State private var groups = NotificationGroup.samples

    var body: some View {
        VStack(spacing: 0) {
            FiHeader(
                title: "Notificaciones",
                leading: .back,
                trailingIcon: "trash",
                onLeading: { router.pop() },
                onTrailing: { groups.removeAll() }
            )

            ScrollView {
                VStack(spacing: 8) {
                    Button(action: markAllRead) {
                        Text("Marcar todas como leídas")
                            .font(.poppins(11, .semibold))
                            .foregroundStyle(Color.fiTeal)
                            .frame(maxWidth: .infinity)
                            .frame(height: 32)
                            .cardStyle(cornerRadius: 8, border: .fiCardBorder)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 22)

                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(groups) { group in
                            HStack {
                                Text(group.title)
                                    .font(.inter(8, .semibold))
                                    .foregroundStyle(Color.fiGrayText)
                                Spacer()
                                let newCount = group.items.filter(\.unread).count
                                if newCount > 0 {
                                    Text("\(newCount) nuevas")
                                        .font(.inter(8, .medium))
                                        .foregroundStyle(Color.fiGrayText)
                                }
                            }
                            .padding(.top, 6)

                            ForEach(group.items) { item in
                                NotificationCardView(item: item)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.fiNotificationBackground)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 16)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private func markAllRead() {
        for g in groups.indices {
            for i in groups[g].items.indices { groups[g].items[i].unread = false }
        }
    }
}

#Preview {
    NotificationsView().environment(AppRouter())
}
