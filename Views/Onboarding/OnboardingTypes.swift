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

    // MARK: - Demographic Expansion
    case socialMediaComparison = "Social Media Comparison"
    case peoplePleasing = "People-Pleasing"
    case perfectionism = "Perfectionism"
    case skincareSelfCare = "Self-Care Routine"
    case careerParalysis = "Career Paralysis"
    case financialChaos = "Financial Chaos"
    case substanceDependency = "Substance Dependency"
    case relationshipAvoidance = "Relationship Avoidance"
    case fitnessRegression = "Fitness Regression"
    case sleepQuality = "Sleep Quality"
    case alcoholModeration = "Alcohol Moderation"
    case workLifeBalance = "Work-Life Balance"
    case selfCareGuilt = "Self-Care Guilt"
    case stressManagement = "Stress Management"

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
        case .socialMediaComparison: return "Comparing myself to others online."
        case .peoplePleasing: return "Saying yes when I want to say no."
        case .perfectionism: return "All-or-nothing thinking."
        case .skincareSelfCare: return "Can't maintain a self-care routine."
        case .careerParalysis: return "Don't know what I'm doing with my career."
        case .financialChaos: return "Can't get my money under control."
        case .substanceDependency: return "Using substances to cope."
        case .relationshipAvoidance: return "Avoiding real connections."
        case .fitnessRegression: return "Losing the shape I used to be in."
        case .sleepQuality: return "Can't get quality sleep anymore."
        case .alcoholModeration: return "Drinking more than I want to."
        case .workLifeBalance: return "Work is consuming everything."
        case .selfCareGuilt: return "Feeling guilty for taking time for myself."
        case .stressManagement: return "Constant stress with no outlet."
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
        case .socialMediaComparison: return [.phoneJail, .touchGrass, .brainDump]
        case .peoplePleasing: return [.brainDump, .lockIn, .dailyWs]
        case .perfectionism: return [.dailyWs, .brainDump, .staticStretch]
        case .skincareSelfCare: return [.hydrationMax, .deepSleep, .staticStretch]
        case .careerParalysis: return [.lockIn, .skillUpload, .dailyWs]
        case .financialChaos: return [.brainDump, .lockIn, .financialCheck]
        case .substanceDependency: return [.deepSleep, .combatPrep, .hydrationMax]
        case .relationshipAvoidance: return [.zionCall, .touchGrass, .dailyWs]
        case .fitnessRegression: return [.combatPrep, .proteinFirst, .morningWin]
        case .sleepQuality: return [.deepSleep, .staticStretch, .hydrationMax]
        case .alcoholModeration: return [.hydrationMax, .deepSleep, .touchGrass]
        case .workLifeBalance: return [.lockIn, .touchGrass, .zionCall]
        case .selfCareGuilt: return [.staticStretch, .brainDump, .deepSleep]
        case .stressManagement: return [.staticStretch, .touchGrass, .brainDump]
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
        case .socialMediaComparison: return [.noBrainRot, .noMorningScroll, .noBedScrolling]
        case .peoplePleasing: return [.noSelfSabotage, .noVictimMode, .noOvercommitting]
        case .perfectionism: return [.noSelfSabotage, .noVictimMode, .noRageBait]
        case .skincareSelfCare: return [.noLateNight, .noBedScrolling, .noSelfSabotage]
        case .careerParalysis: return [.noBrainRot, .noBingeGaming, .noImpulseBuys]
        case .financialChaos: return [.noImpulseBuys, .noSelfSabotage, .noBrainRot]
        case .substanceDependency: return [.noLateNight, .noSelfSabotage, .noWineDefault]
        case .relationshipAvoidance: return [.noGhostingIRL, .noBedScrolling, .noBrainRot]
        case .fitnessRegression: return [.noChairLock, .noSnooze, .noJunkMeals]
        case .sleepQuality: return [.noBedScrolling, .noLateNight, .noSlopContent]
        case .alcoholModeration: return [.noLateNight, .noSelfSabotage, .noWineDefault]
        case .workLifeBalance: return [.noBrainRot, .noChairLock, .noOvercommitting]
        case .selfCareGuilt: return [.noSelfSabotage, .noVictimMode, .noOvercommitting]
        case .stressManagement: return [.noRageBait, .noBrainRot, .noLateNight]
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
        case .selfCareGuilt: return 1
        case .sleepQuality: return 1
        case .peoplePleasing: return 2
        case .fitnessRegression: return 2
        case .substanceDependency: return 2
        case .alcoholModeration: return 2
        case .socialMediaComparison: return 3
        case .careerParalysis: return 3
        case .workLifeBalance: return 3
        case .stressManagement: return 3
        case .perfectionism: return 4
        case .financialChaos: return 5
        case .skincareSelfCare: return 6
        case .relationshipAvoidance: return 6
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
        case .doomscrolling, .socialMediaComparison: return .doomscrolling
        case .gamingGambling: return .gaming
        case .junkFood: return .junkFood
        case .bedRotting: return .bedRotting
        case .anxiety, .stressManagement: return .anxiety
        default: return nil
        }
    }

    func agent(for tier: DifficultyTier) -> AgentHabit? {
        guard let family = agentFamily else { return nil }
        return family.agent(for: tier)
    }

    // MARK: - Tier-Filtered Problem Lists

    static func problems(for tier: DemographicTier) -> [ModernProblem] {
        switch tier {
        case .maleYouth:
            return [.doomscrolling, .adultContent, .vaping, .junkFood, .bedRotting, .gamingGambling, .anxiety, .allAbove]
        case .femaleYouth:
            return [.doomscrolling, .socialMediaComparison, .bedRotting, .anxiety, .peoplePleasing, .perfectionism, .junkFood, .allAbove]
        case .maleYoung:
            return [.doomscrolling, .adultContent, .substanceDependency, .careerParalysis, .bedRotting, .financialChaos, .gamingGambling, .anxiety, .allAbove]
        case .femaleYoung:
            return [.doomscrolling, .peoplePleasing, .anxiety, .socialMediaComparison, .perfectionism, .bedRotting, .skincareSelfCare, .substanceDependency, .allAbove]
        case .maleAdult:
            return [.fitnessRegression, .sleepQuality, .alcoholModeration, .workLifeBalance, .doomscrolling, .stressManagement, .financialChaos, .anxiety, .allAbove]
        case .femaleAdult:
            return [.selfCareGuilt, .sleepQuality, .fitnessRegression, .workLifeBalance, .alcoholModeration, .stressManagement, .doomscrolling, .anxiety, .allAbove]
        }
    }

    // MARK: - Tier-Specific Display Labels

    func label(for tier: DemographicTier) -> String {
        switch (self, tier) {
        // Doomscrolling
        case (.doomscrolling, .maleYouth):   return "Doomscrolling"
        case (.doomscrolling, .femaleYouth):  return "Doom scrolling for hours"
        case (.doomscrolling, .maleYoung):    return "Wasting hours on my phone"
        case (.doomscrolling, .femaleYoung):  return "3 hours on TikTok before I notice"
        case (.doomscrolling, .maleAdult):    return "Wasting evenings on my phone"
        case (.doomscrolling, .femaleAdult):  return "Scrolling instead of resting"

        // Adult Content
        case (.adultContent, .maleYoung):     return "Habits I keep relapsing on"
        case (.adultContent, _):              return "Adult Content"

        // Vaping
        case (.vaping, _):                    return "Vaping / Substances"

        // Junk Food
        case (.junkFood, .femaleYouth):       return "Stress eating / skipping meals"
        case (.junkFood, _):                  return "Junk Food / Sugar"

        // Bed Rotting
        case (.bedRotting, .femaleYouth):      return "Can't get out of bed"
        case (.bedRotting, .maleYoung):        return "Can't stay consistent"
        case (.bedRotting, .femaleYoung):      return "No energy to do anything"
        case (.bedRotting, _):                 return "Bed Rotting"

        // Gaming/Gambling
        case (.gamingGambling, .maleYoung):    return "Gaming instead of doing what matters"
        case (.gamingGambling, _):             return "Gaming / Gambling"

        // Anxiety
        case (.anxiety, .femaleYouth):         return "Overthinking everything"
        case (.anxiety, .maleYoung):           return "Can't turn my brain off"
        case (.anxiety, .femaleYoung):         return "Anxiety that won't shut up"
        case (.anxiety, .maleAdult):           return "Constant low-grade stress"
        case (.anxiety, .femaleAdult):         return "Mind won't stop racing"
        case (.anxiety, .maleYouth):           return "Chronic Anxiety"

        // All Above
        case (.allAbove, _):                   return "All of the Above"

        // Social Media Comparison
        case (.socialMediaComparison, .femaleYouth):  return "Comparing myself to everyone online"
        case (.socialMediaComparison, .femaleYoung):  return "Feeling behind everyone else"
        case (.socialMediaComparison, _):             return "Social Media Comparison"

        // People-Pleasing
        case (.peoplePleasing, .femaleYouth):  return "Can't say no to anyone"
        case (.peoplePleasing, .femaleYoung):  return "I can't stop saying yes to everyone"
        case (.peoplePleasing, _):             return "People-Pleasing"

        // Perfectionism
        case (.perfectionism, .femaleYouth):   return "All-or-nothing with routines"
        case (.perfectionism, .femaleYoung):   return "I either do it perfectly or not at all"
        case (.perfectionism, _):              return "Perfectionism"

        // Skincare/Self-Care
        case (.skincareSelfCare, .femaleYoung): return "Can't keep a routine going"
        case (.skincareSelfCare, _):            return "Self-Care Routine"

        // Career Paralysis
        case (.careerParalysis, .maleYoung):    return "Stuck and don't know what I'm doing"
        case (.careerParalysis, _):             return "Career Paralysis"

        // Financial Chaos
        case (.financialChaos, .maleAdult):     return "Spending without a plan"
        case (.financialChaos, _):              return "Financial Chaos"

        // Substance Dependency
        case (.substanceDependency, .femaleYoung): return "Wine/substances to wind down"
        case (.substanceDependency, _):            return "Substance Dependency"

        // Relationship Avoidance
        case (.relationshipAvoidance, _):       return "Relationship Avoidance"

        // Fitness Regression
        case (.fitnessRegression, .femaleAdult): return "Can't find time to exercise"
        case (.fitnessRegression, _):            return "Not in the shape I used to be"

        // Sleep Quality
        case (.sleepQuality, .femaleAdult):      return "Haven't slept properly in months"
        case (.sleepQuality, _):                 return "Sleep is getting worse"

        // Alcohol Moderation
        case (.alcoholModeration, .femaleAdult): return "Using wine to decompress"
        case (.alcoholModeration, _):            return "Drinking more than I should"

        // Work-Life Balance
        case (.workLifeBalance, .femaleAdult):   return "Stretched too thin across everything"
        case (.workLifeBalance, _):              return "Work is consuming my life"

        // Self-Care Guilt
        case (.selfCareGuilt, _):                return "Feeling guilty for taking time for myself"

        // Stress Management
        case (.stressManagement, _):             return "Running on empty constantly"
        }
    }
}
