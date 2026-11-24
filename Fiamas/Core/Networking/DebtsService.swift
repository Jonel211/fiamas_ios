import Foundation
import UserNotifications

struct FiadosResponse: Decodable {
    let msg: String
    let total: Int
    let fiados: [FiadoAPI]
}

struct TiendaInfo: Decodable {
    let id: String
    let nombre: String
    let imagenUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, nombre, imagenUrl
    }

    init(id: String, nombre: String, imagenUrl: String? = nil) {
        self.id = id
        self.nombre = nombre
        self.imagenUrl = imagenUrl
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let str = try? container.decode(String.self, forKey: .id) {
            id = str
        } else if let intId = try? container.decode(Int.self, forKey: .id) {
            id = String(intId)
        } else {
            throw DecodingError.keyNotFound(
                CodingKeys.id,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "ID de tienda inválido")
            )
        }
        nombre = (try? container.decode(String.self, forKey: .nombre)) ?? "Tienda"

        if let rawUrl = try? container.decodeIfPresent(String.self, forKey: .imagenUrl) {
            let trimmed = rawUrl.trimmingCharacters(in: .whitespacesAndNewlines)
            imagenUrl = trimmed.isEmpty ? nil : trimmed
        } else {
            imagenUrl = nil
        }
    }
}

struct FiadoDetalleAPI: Decodable {
    let producto: ProductoFiadoAPI?
    let cantidad: Double
    
    let precioUnitario: Double
    let subtotal: Double

    private enum CodingKeys: String, CodingKey {
        case producto, cantidad, precioUnitario, subtotal
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        producto = try? values.decodeIfPresent(ProductoFiadoAPI.self, forKey: .producto)

        func decodeNum(_ key: CodingKeys) -> Double {
            if let number = try? values.decode(Double.self, forKey: key) { return number }
            if let text = try? values.decode(String.self, forKey: key), let number = Double(text) { return number }
            return 0
        }

        cantidad = decodeNum(.cantidad)
        let rawUnitPrice = decodeNum(.precioUnitario)
        precioUnitario = rawUnitPrice > 0 ? rawUnitPrice : (producto?.precioVenta ?? 0)

        let rawSubtotal = decodeNum(.subtotal)
        subtotal = rawSubtotal > 0 ? rawSubtotal : (cantidad * precioUnitario)
    }
}

struct ProductoFiadoAPI: Decodable {
    let id: String?
    let nombre: String
    let precioVenta: Double?
    let unidadMedida: String?
    let tipoVenta: String?

    private enum CodingKeys: String, CodingKey {
        case id, nombre, precioVenta, unidadMedida, tipoVenta
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let str = try? values.decode(String.self, forKey: .id) {
            id = str
        } else if let intId = try? values.decode(Int.self, forKey: .id) {
            id = String(intId)
        } else {
            id = nil
        }
        nombre = (try? values.decode(String.self, forKey: .nombre)) ?? "Producto"
        unidadMedida = try? values.decodeIfPresent(String.self, forKey: .unidadMedida)
        tipoVenta = try? values.decodeIfPresent(String.self, forKey: .tipoVenta)

        if let val = try? values.decode(Double.self, forKey: .precioVenta) {
            precioVenta = val
        } else if let str = try? values.decode(String.self, forKey: .precioVenta), let val = Double(str) {
            precioVenta = val
        } else {
            precioVenta = nil
        }
    }
}

struct FiadoAPI: Decodable, Identifiable {
    let id: String
    let tienda: TiendaInfo?
    let montoTotal: Double
    let montoPagado: Double
    let saldoPendiente: Double
    let estado: String
    let fechaCreacion: String
    let fechaVencimiento: String?
    let detalles: [FiadoDetalleAPI]

    var dueDate: Date? {
        guard let fechaVencimiento else { return nil }
        let parts = fechaVencimiento.prefix(10).split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        return Calendar.current.date(from: DateComponents(year: parts[0], month: parts[1], day: parts[2]))
    }

    var daysUntilDue: Int? {
        guard saldoPendiente > 0, !["pagado", "cancelado"].contains(estado.lowercased()),
              let dueDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: .now), to: dueDate).day
    }

    enum CodingKeys: String, CodingKey {
        case id, tienda, estado
        case montoTotal, montoPagado, saldoPendiente, fechaCreacion, fechaVencimiento, detalles
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let str = try? container.decode(String.self, forKey: .id) {
            id = str
        } else if let intId = try? container.decode(Int.self, forKey: .id) {
            id = String(intId)
        } else {
            throw DecodingError.keyNotFound(
                CodingKeys.id,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "ID de fiado inválido")
            )
        }

        tienda = try? container.decodeIfPresent(TiendaInfo.self, forKey: .tienda)
        estado = (try? container.decode(String.self, forKey: .estado)) ?? "pendiente"
        fechaCreacion = (try? container.decode(String.self, forKey: .fechaCreacion)) ?? "Sin fecha"
        fechaVencimiento = try? container.decodeIfPresent(String.self, forKey: .fechaVencimiento)
        detalles = (try? container.decodeIfPresent([FiadoDetalleAPI].self, forKey: .detalles)) ?? []

        func decodeDouble(forKey key: CodingKeys) -> Double {
            if let val = try? container.decode(Double.self, forKey: key) { return val }
            if let str = try? container.decode(String.self, forKey: key), let val = Double(str) { return val }
            return 0.0
        }

        montoTotal = decodeDouble(forKey: .montoTotal)
        montoPagado = decodeDouble(forKey: .montoPagado)
        saldoPendiente = decodeDouble(forKey: .saldoPendiente)
    }
}

enum ReminderScheduler {
    static func sync(_ fiados: [FiadoAPI]) async {
        let center = UNUserNotificationCenter.current()
        do {
            let settings = await center.notificationSettings()
            let allowed = settings.authorizationStatus == .notDetermined
                ? try await center.requestAuthorization(options: [.alert, .badge, .sound])
                : settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
            guard allowed else { return }

            let previous = await center.pendingNotificationRequests()
                .map(\.identifier).filter { $0.hasPrefix("fiamas-fiado-") }
            center.removePendingNotificationRequests(withIdentifiers: previous)

            for fiado in fiados.filter({ ($0.daysUntilDue ?? -1) > 0 })
                .sorted(by: { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }).prefix(30) {
                guard let dueDate = fiado.dueDate, let days = fiado.daysUntilDue, days > 0 else { continue }
                for offset in [2, 1] {
                    guard let day = Calendar.current.date(byAdding: .day, value: -offset, to: dueDate) else { continue }
                    let content = UNMutableNotificationContent()
                    content.title = offset == 1 ? "Tu fiado vence mañana" : "Tu fiado vence en 2 días"
                    content.body = "\(fiado.tienda?.nombre ?? "Tu tienda"): tienes S/ \(String(format: "%.2f", fiado.saldoPendiente)) pendientes."
                    content.sound = .default
                    var date = Calendar.current.dateComponents([.year, .month, .day], from: day)
                    date.hour = 9
                    date.minute = 0
                    guard let fireDate = Calendar.current.date(from: date), fireDate > .now else { continue }
                    let request = UNNotificationRequest(
                        identifier: "fiamas-fiado-\(fiado.id)-\(offset)", content: content,
                        trigger: UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
                    )
                    try await center.add(request)
                }
            }
        } catch {
            // Los avisos dentro de la app siguen disponibles aunque el sistema deniegue permisos.
        }
    }
}

class DebtsService {
    static let shared = DebtsService()
    private init() {}

    func fetchMyDebts() async throws -> [FiadoAPI] {
        let response: FiadosResponse = try await APIClient.shared.request(endpoint: "/app-cliente/mis-fiados")
        return response.fiados
    }
}
