import SwiftUI

/// iOS-notification
struct NotificationsView: View {
    @Environment(AppRouter.self) private var router

    @State private var groups: [NotificationGroup] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var isConfirmingDelete = false

    private var userKey: String { UserDefaults.standard.string(forKey: "user_id") ?? "guest" }
    private var readKey: String { "readReminders_\(userKey)" }
    private var deletedKey: String { "deletedReminders_\(userKey)" }

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

            if isLoading {
                ProgressView("Cargando avisos...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage {
                Text(errorMessage)
                    .font(.poppins(14))
                    .foregroundStyle(Color.fiDanger)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if groups.isEmpty {
                emptyState
            } else {
                list
            }
        }
        .background(Color.white.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .task { await loadReminders() }
        .confirmationDialog("¿Eliminar todas las notificaciones?", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
            Button("Eliminar todas", role: .destructive) {
                var deleted = Set(UserDefaults.standard.stringArray(forKey: deletedKey) ?? [])
                deleted.formUnion(groups.flatMap(\.items).map(\.id))
                UserDefaults.standard.set(Array(deleted), forKey: deletedKey)
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
                                var read = Set(UserDefaults.standard.stringArray(forKey: readKey) ?? [])
                                read.insert(item.id)
                                UserDefaults.standard.set(Array(read), forKey: readKey)
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
        .refreshable { await loadReminders() }
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
        var read = Set(UserDefaults.standard.stringArray(forKey: readKey) ?? [])
        withAnimation(.easeOut(duration: 0.2)) {
            for g in groups.indices {
                for i in groups[g].items.indices {
                    read.insert(groups[g].items[i].id)
                    groups[g].items[i].unread = false
                }
            }
        }
        UserDefaults.standard.set(Array(read), forKey: readKey)
    }

    private func loadReminders() async {
        isLoading = true
        errorMessage = nil
        do {
            let fiados = try await DebtsService.shared.fetchMyDebts()
            let read = Set(UserDefaults.standard.stringArray(forKey: readKey) ?? [])
            let deleted = Set(UserDefaults.standard.stringArray(forKey: deletedKey) ?? [])
            let items: [AppNotification] = fiados.compactMap { fiado in
                guard let days = fiado.daysUntilDue, days <= 2 else { return nil }
                let id = "\(fiado.id)-\(fiado.fechaVencimiento ?? "")-\(days < 0 ? "mora" : String(days))"
                guard !deleted.contains(id) else { return nil }
                let title = days < 0 ? "Pago vencido" : days == 0 ? "Tu fiado vence hoy"
                    : days == 1 ? "Tu fiado vence mañana" : "Tu fiado vence en 2 días"
                let message = "\(fiado.tienda?.nombre ?? "Tu tienda"): saldo pendiente S/ \(String(format: "%.2f", fiado.saldoPendiente)). Vence el \(fiado.fechaVencimiento?.prefix(10) ?? "")."
                return AppNotification(
                    id: id, kind: days < 0 ? .overdue : .dueSoon,
                    time: days < 0 ? "Vencido" : days == 0 ? "Hoy" : days == 1 ? "1 día" : "2 días",
                    title: title,
                    message: message, unread: !read.contains(id)
                )
            }
            groups = items.isEmpty ? [] : [NotificationGroup(title: "Avisos de tus fiados", items: items)]
        } catch {
            errorMessage = "No se pudieron cargar los avisos: \(error.localizedDescription)"
        }
        isLoading = false
    }
}

#Preview {
    NotificationsView().environment(AppRouter())
}
