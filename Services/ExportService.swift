import Foundation
import SwiftData

@MainActor
final class ExportService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Export

    func exportToJSON() throws -> Data {
        let powers = try fetchAllPowers()
        let agents = try fetchAllAgents()

        let export = ExportData(
            exportDate: Date(),
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0",
            profile: ProfileExport(
                operativeName: UserProfile.operativeName,
                firstLaunchDate: UserProfile.firstLaunchDate
            ),
            powers: powers.map { PowerExport(from: $0) },
            agents: agents.map { AgentExport(from: $0) }
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        return try encoder.encode(export)
    }

    func exportFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: Date())
        return "MatrixHabit_Export_\(dateString).json"
    }

    // MARK: - Private

    private func fetchAllPowers() throws -> [Power] {
        let descriptor = FetchDescriptor<Power>(sortBy: [SortDescriptor(\.createdAt)])
        return try modelContext.fetch(descriptor)
    }

    private func fetchAllAgents() throws -> [Agent] {
        let descriptor = FetchDescriptor<Agent>(sortBy: [SortDescriptor(\.createdAt)])
        return try modelContext.fetch(descriptor)
    }
}

// MARK: - Export Models

struct ExportData: Codable {
    let exportDate: Date
    let appVersion: String
    let profile: ProfileExport
    let powers: [PowerExport]
    let agents: [AgentExport]
}

struct ProfileExport: Codable {
    let operativeName: String?
    let firstLaunchDate: Date?
}

struct PowerExport: Codable {
    let id: String
    let name: String
    let icon: String
    let createdAt: Date
    let isUnlocked: Bool
    let unlockedAt: Date?
    let checkIns: [CheckInExport]

    init(from power: Power) {
        self.id = power.id.uuidString
        self.name = power.name
        self.icon = power.icon
        self.createdAt = power.createdAt
        self.isUnlocked = power.isUnlocked
        self.unlockedAt = power.unlockedAt
        self.checkIns = power.checkIns.map { CheckInExport(from: $0) }
    }
}

struct AgentExport: Codable {
    let id: String
    let name: String
    let icon: String
    let createdAt: Date
    let isDefeated: Bool
    let defeatedAt: Date?
    let checkIns: [CheckInExport]

    init(from agent: Agent) {
        self.id = agent.id.uuidString
        self.name = agent.name
        self.icon = agent.icon
        self.createdAt = agent.createdAt
        self.isDefeated = agent.isDefeated
        self.defeatedAt = agent.defeatedAt
        self.checkIns = agent.checkIns.map { CheckInExport(from: $0) }
    }
}

struct CheckInExport: Codable {
    let date: Date
    let isSuccess: Bool
    let note: String?

    init(from checkIn: CheckIn) {
        self.date = checkIn.date
        self.isSuccess = checkIn.isSuccess
        self.note = checkIn.note
    }
}
