import Foundation

struct Credit: Identifiable {
    enum Status { case overdue, pending }

    let id = UUID()
    let amount: String
    let items: String
    let date: String
    let status: Status
    let footnote: String
}
