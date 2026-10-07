import Foundation

extension NotificationGroup {
    static let samples: [NotificationGroup] = [
        NotificationGroup(title: "HOY", items: [
            AppNotification(kind: .overdue, time: "Hace 2 horas", title: "Tienes un pago vencido",
                            message: "El fiado #00118 de Bodega San Antonio está vencido hace 13 días. Debes S/ 95.00.", unread: true),
            AppNotification(kind: .reminder, time: "Hace 5 horas", title: "Recuerda tu pago pendiente",
                            message: "Tienes S/ 20.00 pendientes en Bodega San Antonio. Cuando puedas, acércate a cancelarlos.", unread: true),
        ]),
        NotificationGroup(title: "AYER", items: [
            AppNotification(kind: .dueSoon, time: "Ayer 9:15 am", title: "Tu fiado vence pronto",
                            message: "El fiado #00123 de Bodega San Antonio vence el 30 de septiembre.", unread: false),
        ]),
        NotificationGroup(title: "ESTA SEMANA", items: [
            AppNotification(kind: .reminder, time: "Hace 3 días", title: "Recuerda tu pago pendiente",
                            message: "Tienes S/ 45.50 pendientes en Minimarket El Sol.", unread: false),
        ]),
    ]
}
