import Foundation
import SwiftData

@MainActor
final class DataManager: ObservableObject {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Power Operations

    func createPower(name: String, icon: String = "bolt") throws -> Power {
        // Validate name
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw DataError.emptyName
        }
        guard trimmedName.count <= 50 else {
            throw DataError.nameTooLong
        }

        // Check for duplicate
        let existingPowers = try fetchPowers()
        if existingPowers.contains(where: { $0.name.lowercased() == trimmedName.lowercased() }) {
            throw DataError.duplicateName
        }

        let power = Power(name: trimmedName, icon: icon)
        modelContext.insert(power)
        try modelContext.save()
        return power
    }

    func fetchPowers() throws -> [Power] {
        let descriptor = FetchDescriptor<Power>(sortBy: [SortDescriptor(\.createdAt, order: .forward)])
        return try modelContext.fetch(descriptor)
    }

    func fetchActivePowers() throws -> [Power] {
        let predicate = #Predicate<Power> { !$0.isUnlocked }
        let descriptor = FetchDescriptor<Power>(predicate: predicate, sortBy: [SortDescriptor(\.createdAt)])
        return try modelContext.fetch(descriptor)
    }

    func fetchUnlockedPowers() throws -> [Power] {
        let predicate = #Predicate<Power> { $0.isUnlocked }
        let descriptor = FetchDescriptor<Power>(predicate: predicate, sortBy: [SortDescriptor(\.unlockedAt)])
        return try modelContext.fetch(descriptor)
    }

    func deletePower(_ power: Power) throws {
        modelContext.delete(power)
        try modelContext.save()
    }

    func updatePower(_ power: Power, name: String? = nil, icon: String? = nil) throws {
        if let newName = name {
            let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedName.isEmpty else {
                throw DataError.emptyName
            }
            guard trimmedName.count <= 50 else {
                throw DataError.nameTooLong
            }
            power.name = trimmedName
        }
        if let newIcon = icon {
            power.icon = newIcon
        }
        try modelContext.save()
    }

    // MARK: - Agent Operations

    func createAgent(name: String, icon: String = "xmark.shield") throws -> Agent {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw DataError.emptyName
        }
        guard trimmedName.count <= 50 else {
            throw DataError.nameTooLong
        }

        let existingAgents = try fetchAgents()
        if existingAgents.contains(where: { $0.name.lowercased() == trimmedName.lowercased() }) {
            throw DataError.duplicateName
        }

        let agent = Agent(name: trimmedName, icon: icon)
        modelContext.insert(agent)
        try modelContext.save()
        return agent
    }

    func fetchAgents() throws -> [Agent] {
        let descriptor = FetchDescriptor<Agent>(sortBy: [SortDescriptor(\.createdAt, order: .forward)])
        return try modelContext.fetch(descriptor)
    }

    func fetchActiveAgents() throws -> [Agent] {
        let predicate = #Predicate<Agent> { !$0.isDefeated }
        let descriptor = FetchDescriptor<Agent>(predicate: predicate, sortBy: [SortDescriptor(\.createdAt)])
        return try modelContext.fetch(descriptor)
    }

    func fetchDefeatedAgents() throws -> [Agent] {
        let predicate = #Predicate<Agent> { $0.isDefeated }
        let descriptor = FetchDescriptor<Agent>(predicate: predicate, sortBy: [SortDescriptor(\.defeatedAt)])
        return try modelContext.fetch(descriptor)
    }

    func deleteAgent(_ agent: Agent) throws {
        modelContext.delete(agent)
        try modelContext.save()
    }

    func updateAgent(_ agent: Agent, name: String? = nil, icon: String? = nil) throws {
        if let newName = name {
            let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedName.isEmpty else {
                throw DataError.emptyName
            }
            guard trimmedName.count <= 50 else {
                throw DataError.nameTooLong
            }
            agent.name = trimmedName
        }
        if let newIcon = icon {
            agent.icon = newIcon
        }
        try modelContext.save()
    }

    // MARK: - Check-In Operations

    func logCheckIn(for power: Power, isSuccess: Bool = true, note: String? = nil, date: Date = Date()) throws {
        // Check for duplicate check-in on same day
        let targetDate = Calendar.current.startOfDay(for: date)
        let hasExisting = power.checkIns.contains {
            Calendar.current.startOfDay(for: $0.date) == targetDate
        }
        guard !hasExisting else {
            throw DataError.duplicateCheckIn
        }

        let checkIn = CheckIn(date: date, isSuccess: isSuccess, note: note)
        checkIn.power = power
        power.checkIns.append(checkIn)
        modelContext.insert(checkIn)

        // Check if Power should be unlocked
        power.checkForUnlock()

        try modelContext.save()
    }

    func logCheckIn(for agent: Agent, isSuccess: Bool, note: String? = nil, date: Date = Date()) throws {
        let targetDate = Calendar.current.startOfDay(for: date)
        let hasExisting = agent.checkIns.contains {
            Calendar.current.startOfDay(for: $0.date) == targetDate
        }
        guard !hasExisting else {
            throw DataError.duplicateCheckIn
        }

        let checkIn = CheckIn(date: date, isSuccess: isSuccess, note: note)
        checkIn.agent = agent
        agent.checkIns.append(checkIn)
        modelContext.insert(checkIn)

        // Check if Agent should be defeated
        agent.checkForDefeat()

        try modelContext.save()
    }

    func fetchTodaysCheckIns() throws -> [CheckIn] {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        let predicate = #Predicate<CheckIn> { checkIn in
            checkIn.date >= today && checkIn.date < tomorrow
        }
        let descriptor = FetchDescriptor<CheckIn>(predicate: predicate)
        return try modelContext.fetch(descriptor)
    }

    // MARK: - Stats

    func totalCheckIns() throws -> Int {
        let descriptor = FetchDescriptor<CheckIn>()
        return try modelContext.fetchCount(descriptor)
    }

    func longestStreakAcrossAll() throws -> Int {
        let powers = try fetchPowers()
        let agents = try fetchAgents()

        let powerMax = powers.map { $0.longestStreak }.max() ?? 0
        let agentMax = agents.map { $0.longestStreak }.max() ?? 0

        return max(powerMax, agentMax)
    }
}

// MARK: - Errors

enum DataError: LocalizedError {
    case emptyName
    case nameTooLong
    case duplicateName
    case duplicateCheckIn

    var errorDescription: String? {
        switch self {
        case .emptyName:
            return "Name cannot be empty"
        case .nameTooLong:
            return "Name must be 50 characters or less"
        case .duplicateName:
            return "A habit with this name already exists"
        case .duplicateCheckIn:
            return "Already checked in today"
        }
    }
}
