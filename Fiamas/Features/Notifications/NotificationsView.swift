import SwiftUI

/// iOS-notification
struct NotificationsView: View {
    @Environment(AppRouter.self) private var router

    @State private var groups = NotificationGroup.samples
    @State private var isConfirmingDelete = false

    private var unreadCount: Int {
        groups.flatMap(\.items).filter(\.unread).count
    }

    var body: some View {
        VStack(spacing: 0) {
            FiHeader(
                title: "Notificaciones",
                leading: .back,
                trailingIcon: groups.isEmpty ? nil : "trash",
                onLeading: { router.pop() },
                onTrailing: { isConfirmingDelete = true }
            )

            if groups.isEmpty {
                emptyState
            } else {
                list
            }
        }
        .background(Color.white.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .confirmationDialog("¿Eliminar todas las notificaciones?", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
            Button("Eliminar todas", role: .destructive) {
                withAnimation { groups.removeAll() }
            }
        }
    }

    private var list: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(unreadCount == 0 ? "Todo al día" : "\(unreadCount) sin leer")
                        .font(.poppins(14, .medium))
                        .foregroundStyle(Color.fiTextSecondary)
                    Spacer()
                    if unreadCount > 0 {
                        Button(action: markAllRead) {
                            Text("Marcar todas como leídas")
                                .font(.poppins(14, .medium))
                                .foregroundStyle(Color.fiTeal)
                        }
                    }
                }
                .padding(.top, 16)

                ForEach($groups) { $group in
                    Text(group.title)
                        .font(.poppins(15, .semibold))
                        .foregroundStyle(Color.fiTextPrimary)
                        .padding(.top, 24)
                        .padding(.bottom, 2)

                    ForEach($group.items) { $item in
                        NotificationCardView(item: item)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.easeOut(duration: 0.2)) { item.unread = false }
                            }

                        if item.id != group.items.last?.id {
                            FiDivider(leadingInset: 36)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bell.slash")
                .font(.system(size: 36, weight: .light))
                .foregroundStyle(Color.fiTextTertiary)
            Text("No tienes notificaciones")
                .font(.poppins(16, .medium))
                .foregroundStyle(Color.fiTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func markAllRead() {
        withAnimation(.easeOut(duration: 0.2)) {
            for g in groups.indices {
                for i in groups[g].items.indices { groups[g].items[i].unread = false }
            }
        }
    }
}

#Preview {
    NotificationsView().environment(AppRouter())
}
