import Foundation

enum Rank: String, CaseIterable {
    case copperTop = "COPPER TOP"
    case nebuchadnezzarCrew = "NEBUCHADNEZZAR CREW"
    case `operator` = "OPERATOR"
    case zionCaptain = "ZION CAPTAIN"
    case theOne = "THE ONE"

    var minLevel: Int {
        switch self {
        case .copperTop: return 1
        case .nebuchadnezzarCrew: return 6
        case .operator: return 11
        case .zionCaptain: return 21
        case .theOne: return 50
        }
    }

    var quote: String {
        switch self {
        case .copperTop:
            return "Born into a prison that you cannot smell or taste or touch."
        case .nebuchadnezzarCrew:
            return "Unplugged, but raw."
        case .operator:
            return "I see the code."
        case .zionCaptain:
            return "A leader of self. Strong will."
        case .theOne:
            return "When you're ready, you won't have to."
        }
    }
}

enum RankSystem {
    // XP thresholds per level (cumulative)
    // Level 1: 0 XP, Level 2: 100 XP, Level 3: 250 XP, etc.
    private static let xpPerLevel: [Int] = {
        var levels = [0]
        var total = 0
        for level in 1...60 {
            total += 50 + (level * 10) // Progressive XP requirement
            levels.append(total)
        }
        return levels
    }()

    static func levelFromXP(_ xp: Int) -> Int {
        for (level, threshold) in xpPerLevel.enumerated().reversed() {
            if xp >= threshold {
                return level + 1
            }
        }
        return 1
    }

    static func rankFromLevel(_ level: Int) -> Rank {
        switch level {
        case 1...5: return .copperTop
        case 6...10: return .nebuchadnezzarCrew
        case 11...20: return .operator
        case 21...49: return .zionCaptain
        default: return .theOne
        }
    }

    static func rankFromXP(_ xp: Int) -> Rank {
        return rankFromLevel(levelFromXP(xp))
    }

    static func xpForNextLevel(_ currentXP: Int) -> Int {
        let currentLevel = levelFromXP(currentXP)
        if currentLevel >= xpPerLevel.count {
            return 0
        }
        return xpPerLevel[currentLevel] - currentXP
    }

    static func progressToNextLevel(_ currentXP: Int) -> Double {
        let currentLevel = levelFromXP(currentXP)
        if currentLevel >= xpPerLevel.count {
            return 1.0
        }
        let currentLevelXP = xpPerLevel[currentLevel - 1]
        let nextLevelXP = xpPerLevel[currentLevel]
        let xpIntoLevel = currentXP - currentLevelXP
        let xpNeeded = nextLevelXP - currentLevelXP
        return Double(xpIntoLevel) / Double(xpNeeded)
    }
}
