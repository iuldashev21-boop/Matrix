import Foundation

// MARK: - Modern Problem Types

enum ModernProblem: String, CaseIterable, Identifiable {
    case doomscrolling = "Doomscrolling"
    case adultContent = "Adult Content"
    case vaping = "Vaping / Substances"
    case junkFood = "Junk Food / Sugar"
    case bedRotting = "Bed Rotting"
    case gamingGambling = "Gaming / Gambling"
    case anxiety = "Chronic Anxiety"
    case allAbove = "All of the Above"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .doomscrolling: return "Losing hours to TikTok, Reels, or infinite feeds."
        case .adultContent: return "Cheap dopamine that kills your drive."
        case .vaping: return "Numbing stress instead of solving it."
        case .junkFood: return "Eating for sedation, not fuel."
        case .bedRotting: return "Procrastination disguised as comfort."
        case .gamingGambling: return "Chasing the high. Whether it's a rank or a payout."
        case .anxiety: return "Overthinking and paralysis."
        case .allAbove: return "I struggle with multiple issues."
        }
    }

    // 3 Powers (good habits to BUILD)
    var suggestedHacks: [HackHabit] {
        switch self {
        case .doomscrolling: return [.phoneJail, .lockIn, .touchGrass]
        case .adultContent: return [.coldReboot, .combatPrep, .zionCall, .phoneJail, .touchGrass]
        case .vaping: return [.hydrationMax, .staticStretch, .touchGrass]
        case .junkFood: return [.proteinFirst, .hydrationMax, .touchGrass]
        case .bedRotting: return [.solarLoad, .morningWin, .coldReboot]
        case .gamingGambling: return [.lockIn, .skillUpload, .touchGrass]
        case .anxiety: return [.brainDump, .staticStretch, .touchGrass]
        case .allAbove: return [.touchGrass, .hydrationMax, .morningWin]
        }
    }

    // 3 Agents (bad habits to DEFEAT)
    var suggestedAgents: [AgentHabit] {
        switch self {
        case .doomscrolling: return [.noMorningScroll, .noBrainRot, .noBedScrolling]
        case .adultContent: return [.noPMO, .noBedScrolling, .noBrainRot, .noChairLock]
        case .vaping: return [.noVaping, .noLiquidSugar, .noChairLock]
        case .junkFood: return [.noJunkMeals, .noLiquidSugar, .noImpulseBuys]
        case .bedRotting: return [.noSnooze, .noBedScrolling, .noChairLock]
        case .gamingGambling: return [.noBingeGaming, .noImpulseBuys, .noBrainRot]
        case .anxiety: return [.noRageBait, .noLiquidSugar, .noLateNight]
        case .allAbove: return [.noBrainRot, .noJunkMeals, .noBedScrolling]
        }
    }

    // Priority ranking (lower = higher priority)
    var priority: Int {
        switch self {
        case .bedRotting: return 1
        case .adultContent: return 2
        case .doomscrolling: return 3
        case .gamingGambling: return 4
        case .vaping: return 5
        case .junkFood: return 6
        case .anxiety: return 7
        case .allAbove: return 99
        }
    }

    var isDirectProblem: Bool {
        switch self {
        case .anxiety, .allAbove: return false
        default: return true
        }
    }

    var primaryAgent: AgentHabit? {
        return suggestedAgents.first
    }

    var primaryPower: HackHabit? {
        return suggestedHacks.first
    }

    // MARK: - V2 Algorithm: Agent Family Mapping

    var agentFamily: AgentFamily? {
        switch self {
        case .adultContent: return .pmo
        case .vaping: return .vaping
        case .doomscrolling: return .doomscrolling
        case .gamingGambling: return .gaming
        case .junkFood: return .junkFood
        case .bedRotting: return .bedRotting
        case .anxiety: return .anxiety
        case .allAbove: return nil
        }
    }

    func agent(for tier: DifficultyTier) -> AgentHabit? {
        guard let family = agentFamily else { return nil }
        return family.agent(for: tier)
    }
}
