import Foundation
import Observation

enum RefreshPolicy {
    static let minimumInterval: TimeInterval = 5
    static let pollingInterval: Duration = .seconds(30)
}

@MainActor @Observable
final class DebtsStore {
    private(set) var fiadosAPI: [FiadoAPI] = []
    private(set) var storeSummaries: [StoreSummary] = []
    private(set) var clientScore: Int?
    private(set) var clientCategory = "Sin historial"
    private(set) var totalOwed: Double = 0
    private(set) var hasLoadedOnce = false
    private(set) var errorMessage: String?
    private(set) var refreshBannerMessage: String?

    @ObservationIgnored private var isRefreshing = false
    @ObservationIgnored private var lastAttempt: Date?
    @ObservationIgnored private var lastReminderSignature: [String]?

    func refresh(profileStore: ProfileStore) async {
        guard !isRefreshing else { return }
        let now = Date()
        if let lastAttempt, now.timeIntervalSince(lastAttempt) < RefreshPolicy.minimumInterval { return }
        isRefreshing = true
        lastAttempt = now
        defer { isRefreshing = false }

        do {
            async let debtsTask = DebtsService.shared.fetchMyDebts()
            async let summaryTask = SummaryService.shared.fetchMySummary()
            let (debts, summary) = try await (debtsTask, summaryTask)
            try Task.checkCancellation()
            fiadosAPI = debts
            storeSummaries = summary.stores
            totalOwed = summary.totalOwed
            clientScore = summary.score
            clientCategory = summary.category
            profileStore.updateScoring(score: summary.score, category: summary.category)
            hasLoadedOnce = true
            errorMessage = nil
            refreshBannerMessage = nil
            let reminderSignature = debts.map { "\($0.id)|\($0.saldoPendiente)|\($0.estado)|\($0.fechaVencimiento ?? "")" }
            if reminderSignature != lastReminderSignature {
                lastReminderSignature = reminderSignature
                await ReminderScheduler.sync(debts)
            }
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
