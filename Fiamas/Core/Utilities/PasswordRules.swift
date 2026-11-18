enum PasswordRules {
    static let maxLength = 6

    static func limit(_ value: String) -> String {
        String(value.prefix(maxLength))
    }

    static func isValid(_ value: String) -> Bool {
        value.count == maxLength
    }
}
