import Foundation
import Observation

@MainActor @Observable
final class PaymentsStore {
    private(set) var pagosAPI: [PaymentAPI] = []
    private(set) var hasLoadedOnce = false
    private(set) var errorMessage: String?
    private(set) var refreshBannerMessage: String?

    @ObservationIgnored private var isRefreshing = false
    @ObservationIgnored private var lastAttempt: Date?

    func refresh() async {
        guard !isRefreshing else { return }
        let now = Date()
        if let lastAttempt, now.timeIntervalSince(lastAttempt) < RefreshPolicy.minimumInterval { return }
        isRefreshing = true
        lastAttempt = now
        defer { isRefreshing = false }

        do {
            let payments = try await PaymentService.shared.fetchMyPayments()
            try Task.checkCancellation()
            pagosAPI = payments
            hasLoadedOnce = true
            errorMessage = nil
            refreshBannerMessage = nil
        } catch is CancellationError {
            lastAttempt = nil
        } catch {
            if Task.isCancelled { lastAttempt = nil; return }
            if hasLoadedOnce {
                refreshBannerMessage = "No se pudo actualizar. Mostrando últimos datos guardados."
            } else {
                errorMessage = error.localizedDescription
            }
        }
    }
}
