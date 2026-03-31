import Foundation
import SwiftData
import WidgetKit

enum WidgetSyncService {

    /// Processes pending check-ins written by the widget extension.
    /// Call this when the app enters foreground.
    @MainActor
    static func syncPendingCheckIns(context: ModelContext) {
        let pending = WidgetDataManager.readPendingCheckIns()
        guard !pending.isEmpty else { return }

        // Fetch all habits — abort sync if fetch fails to avoid losing pending data
        guard let allPowers = try? context.fetch(FetchDescriptor<Power>()),
              let allAgents = try? context.fetch(FetchDescriptor<Agent>()) else {
            return
        }

        for entry in pending {
            if entry.isPower {
                guard let power = allPowers.first(where: { $0.name == entry.habitName }) else { continue }
                CheckInService.recordPowerCheckIn(
                    power: power,
                    date: entry.date,
                    context: context
                )
            } else {
                guard let agent = allAgents.first(where: { $0.name == entry.habitName }) else { continue }
                CheckInService.recordAgentResistance(
                    agent: agent,
                    date: entry.date,
                    context: context
                )
            }
        }

        // Clear pending only after successful fetch + processing
        // (duplicates are handled by CheckInService returning .duplicateCheckIn)
        WidgetDataManager.clearPendingCheckIns()
        WidgetCenter.shared.reloadAllTimelines()
    }
}
