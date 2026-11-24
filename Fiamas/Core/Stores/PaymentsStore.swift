import Foundation
import Observation
import os
import SwiftUI

@MainActor @Observable
final class PaymentsStore {
    @ObservationIgnored private let logger = Logger(subsystem: "com.fiamas", category: "Refresh")
    private(set) var pagosAPI: [PaymentAPI] = []
    private(set) var hasLoadedOnce = false
    private(set) var errorMessage: String?
    private(set) var refreshBannerMessage: String?

    @ObservationIgnored private var isRefreshing = false
    @ObservationIgnored private var lastAttempt: Date?
    @ObservationIgnored private var consecutiveFailures = 0
    @ObservationIgnored private var bannerDismissTask: Task<Void, Never>?

    func refresh(manually: Bool = false) async {
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
            consecutiveFailures = 0
            bannerDismissTask?.cancel()
            withAnimation { refreshBannerMessage = nil }
        } catch is CancellationError {
            logger.debug("PaymentsStore: cancelled")
            lastAttempt = nil
        } catch {
            if Task.isCancelled || RefreshFailure.isCancellation(error) {
                logger.debug("PaymentsStore: cancelled")
                lastAttempt = nil
                return
            }
            logger.error("PaymentsStore: \(String(describing: error), privacy: .public)")
            let unavailable = RefreshFailure.isAvailabilityFailure(error)
            consecutiveFailures = unavailable ? consecutiveFailures + 1 : 0
            if hasLoadedOnce {
                if manually && consecutiveFailures >= 2 {
                    showBanner()
                }
            } else {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func showBanner() {
        bannerDismissTask?.cancel()
        withAnimation { refreshBannerMessage = "No se pudo actualizar. Mostrando últimos datos guardados." }
        bannerDismissTask = Task {
            try? await Task.sleep(for: .seconds(4))
            guard !Task.isCancelled else { return }
            withAnimation { refreshBannerMessage = nil }
        }
    }
}
