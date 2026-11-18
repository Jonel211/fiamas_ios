import Foundation

struct CreditItem: Identifiable, Hashable {
    var id: String = UUID().uuidString
    let quantityText: String
    let name: String
    let unitPrice: Double
    let subtotal: Double
}

struct Credit: Identifiable, Hashable {
    enum Status: Hashable { case overdue, pending, partial, paid, cancelled }

    var id: String
    let storeName: String
    let amount: String
    let totalAmountValue: Double
    let paidAmountValue: Double
    let remainingAmountValue: Double
    let items: String
    let itemDetails: [CreditItem]
    let createdAt: String?
    let rawCreatedDate: String
    let date: String
    let status: Status
    let footnote: String

    init(
        id: String = UUID().uuidString,
        storeName: String = "",
        amount: String,
        totalAmountValue: Double = 0,
        paidAmountValue: Double = 0,
        remainingAmountValue: Double = 0,
        items: String,
        itemDetails: [CreditItem] = [],
        createdAt: String? = nil,
        rawCreatedDate: String = "",
        date: String,
        status: Status,
        footnote: String
    ) {
        self.id = id
        self.storeName = storeName
        self.amount = amount
        self.totalAmountValue = totalAmountValue
        self.paidAmountValue = paidAmountValue
        self.remainingAmountValue = remainingAmountValue
        self.items = items
        self.itemDetails = itemDetails
        self.createdAt = createdAt
        self.rawCreatedDate = rawCreatedDate
        self.date = date
        self.status = status
        self.footnote = footnote
    }
}
