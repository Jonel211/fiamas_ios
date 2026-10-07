import Foundation

struct Store: Identifiable {
    let id = UUID()
    let name: String
    var description = "La mejor tienda de mundo"
    var date = "10 sep 2024"
    var used = 140
    var limit = 200
}
