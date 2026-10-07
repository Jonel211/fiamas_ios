import SwiftUI

/// iOS-notification
struct NotificationsView: View {
    @Environment(AppRouter.self) private var router

    @State private var groups = NotificationGroup.samples
    @State private var isConfirmingDelete = false

    private var hasUnread: Bool {
        groups.contains { $0.items.contains(where: \.unread) }
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
                if hasUnread {
                    Button("Marcar todas como leídas", action: markAllRead)
                        .font(.inter(13, .medium))
                        .foregroundStyle(Color.fiTeal)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.top, 14)
                }

                ForEach($groups) { $group in
                    Text(group.title)
                        .font(.inter(13, .semibold))
                        .foregroundStyle(Color.fiTextSecondary)
                        .padding(.top, 22)
                        .padding(.bottom, 4)

                    ForEach($group.items) { $item in
                        NotificationCardView(item: item)
                            .contentShape(Rectangle())
                            .onTapGesture { item.unread = false }

                        if item.id != group.items.last?.id {
                            Rectangle()
                                .fill(Color.fiDivider)
                                .frame(height: 1)
                                .padding(.leading, 36)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "bell.slash")
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(Color.fiLightGrayText)
            Text("No tienes notificaciones")
                .font(.inter(14))
                .foregroundStyle(Color.fiGrayText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
