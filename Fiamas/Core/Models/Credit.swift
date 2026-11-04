import Foundation

struct Credit: Identifiable {
    enum Status { case overdue, pending, partial, paid, cancelled }

    var id = UUID().uuidString
    let amount: String
    let items: String
    let date: String
    let status: Status
    let footnote: String
}
