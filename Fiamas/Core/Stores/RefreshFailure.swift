import Foundation

enum RefreshFailure {
    static func isCancellation(_ error: Error) -> Bool {
        error is CancellationError || (error as? URLError)?.code == .cancelled
    }

    static func isAvailabilityFailure(_ error: Error) -> Bool {
        if let error = error as? APIError, case let .httpError(status, _) = error {
            return status == 429 || status >= 500
        }
        guard let error = error as? URLError else { return false }
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost, .timedOut,
             .cannotConnectToHost, .cannotFindHost, .dnsLookupFailed:
            return true
        default:
            return false
        }
    }
}
