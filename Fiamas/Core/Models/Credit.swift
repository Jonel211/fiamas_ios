import Foundation

struct Credit: Identifiable {
    enum Status { case overdue, pending, partial, paid, cancelled }

    var id: String
    let amount: String
    let items: String
    let createdAt: String?
    let date: String
    let status: Status
    let footnote: String

    init(
        id: String = UUID().uuidString,
        amount: String,
        items: String,
        createdAt: String? = nil,
        date: String,
        status: Status,
        footnote: String
    ) {
        self.id = id
        self.amount = amount
        self.items = items
        self.createdAt = createdAt
        self.date = date
        self.status = status
        self.footnote = footnote
    }
}
