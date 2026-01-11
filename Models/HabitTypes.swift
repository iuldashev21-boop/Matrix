import Foundation

// MARK: - Habit Type Definitions
// Extracted from AwakeningView.swift for better code organization
// These enums define the core habit system used throughout the app

// MARK: - Difficulty Tier

enum DifficultyTier: String, Comparable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"

    private var sortOrder: Int {
        switch self {
        case .easy: return 0
        case .medium: return 1
        case .hard: return 2
        }
    }

    static func < (lhs: DifficultyTier, rhs: DifficultyTier) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }
}

// MARK: - Agent Family (V2 Algorithm)
// Maps problems to tiered agents: Easy → Medium → Hard

enum AgentFamily: String, CaseIterable {
    case pmo           // Adult Content
    case vaping        // Vaping / Substances
    case doomscrolling // Doomscrolling
    case gaming        // Gaming / Gambling
    case junkFood      // Junk Food / Sugar
    case bedRotting    // Bed Rotting
    case anxiety       // Chronic Anxiety

    /// Returns the agent for this family at the specified difficulty tier
    func agent(for tier: DifficultyTier) -> AgentHabit {
        switch self {
        case .pmo:
            switch tier {
            case .easy: return .noPMONightShield
            case .medium: return .noPMODayGuard
            case .hard: return .noPMO
            }

        case .vaping:
            switch tier {
            case .easy: return .noVapingIndoors
            case .medium: return .noVapingBeforeNoon
            case .hard: return .noVaping
            }

        case .doomscrolling:
            switch tier {
            case .easy: return .noBedScrolling
            case .medium: return .noSlopContent
            case .hard: return .noMorningScroll
            }

        case .gaming:
            switch tier {
            case .easy: return .noGamingBeforeWin
            case .medium: return .noBingeGaming
            case .hard: return .noGaming
            }

        case .junkFood:
            switch tier {
            case .easy: return .noLiquidSugar
            case .medium: return .noJunkMeals
            case .hard: return .noPackagedJunk
            }

        case .bedRotting:
            switch tier {
            case .easy: return .morningMaker
            case .medium: return .noReturnToBed
            case .hard: return .noSnooze
            }

        case .anxiety:
            switch tier {
            case .easy: return .noRageBait
            case .medium: return .noLateNight
            case .hard: return .noNewsDoomInput
            }
        }
    }

    /// All agents in this family (Easy, Medium, Hard)
    var allAgents: [AgentHabit] {
        return [agent(for: .easy), agent(for: .medium), agent(for: .hard)]
    }

    /// The "defeated" message shown when user completes 66 days
    var defeatedMessage: String {
        switch self {
        case .pmo: return "The simulation's grip on your desire is broken."
        case .vaping: return "Your lungs remember what clean air feels like."
        case .doomscrolling: return "You control the feed. The feed doesn't control you."
        case .gaming: return "Virtual ranks mean nothing. Real skills matter."
        case .junkFood: return "You fuel your body like a machine, not a garbage disposal."
        case .bedRotting: return "You rise when you decide to rise. Not when you feel like it."
        case .anxiety: return "A calm mind is a weapon. You've sharpened yours."
        }
    }
}

// MARK: - Power Habits (Good habits to BUILD)

enum HackHabit: String, CaseIterable, Hashable {
    case lockIn = "Lock In"
    case touchGrass = "Touch Grass"
    case coldReboot = "Cold Reboot"
    case dailyWs = "Daily Ws"
    case phoneJail = "Phone Jail"
    case proteinFirst = "Protein First"
    case hydrationMax = "Hydration Max"
    case solarLoad = "Solar Load"
    case morningWin = "Morning Win"
    case zionCall = "Zion Call"
    case deepSleep = "Deep Sleep"
    case brainDump = "Brain Dump"
    case combatPrep = "Combat Prep"
    case skillUpload = "Skill Upload"
    case staticStretch = "Static Stretch"

    var habitName: String { rawValue }

    var icon: String {
        switch self {
        case .lockIn: return "brain"
        case .touchGrass: return "figure.walk"
        case .coldReboot: return "snowflake"
        case .dailyWs: return "trophy.fill"
        case .phoneJail: return "iphone.slash"
        case .proteinFirst: return "fork.knife"
        case .hydrationMax: return "drop.fill"
        case .solarLoad: return "sun.max.fill"
        case .morningWin: return "bed.double.fill"
        case .zionCall: return "phone.fill"
        case .deepSleep: return "moon.zzz.fill"
        case .brainDump: return "pencil.and.outline"
        case .combatPrep: return "dumbbell.fill"
        case .skillUpload: return "graduationcap.fill"
        case .staticStretch: return "figure.flexibility"
        }
    }

    var description: String {
        switch self {
        case .lockIn: return "1+ hour of deep, focused work or study."
        case .touchGrass: return "30 mins walking outside, no phone."
        case .coldReboot: return "2-minute cold shower to reset."
        case .dailyWs: return "Write down 3 wins or things you're grateful for."
        case .phoneJail: return "Keep phone in another room for 1 hour."
        case .proteinFirst: return "Prioritize protein in 2+ meals."
        case .hydrationMax: return "Drink 2L+ of water today."
        case .solarLoad: return "Get 5-10 mins of morning sunlight."
        case .morningWin: return "Make bed and clear your desk."
        case .zionCall: return "Voice call or IRL hangout with a friend."
        case .deepSleep: return "In bed by 11:00 PM."
        case .brainDump: return "5 mins of journaling or planning."
        case .combatPrep: return "30-45 mins of intentional exercise."
        case .skillUpload: return "30 mins of learning something new."
        case .staticStretch: return "15 mins of stretching or mobility."
        }
    }

    var shortDescription: String {
        switch self {
        case .lockIn: return "1hr+ deep focus work"
        case .touchGrass: return "30min walk, no phone"
        case .coldReboot: return "2min cold shower"
        case .dailyWs: return "Write 3 daily wins"
        case .phoneJail: return "Phone in another room"
        case .proteinFirst: return "Protein in 2+ meals"
        case .hydrationMax: return "Drink 2L+ water"
        case .solarLoad: return "Morning sunlight"
        case .morningWin: return "Make bed, clear desk"
        case .zionCall: return "Call or meet a friend"
        case .deepSleep: return "In bed by 11pm"
        case .brainDump: return "5min journal/plan"
        case .combatPrep: return "30min+ exercise"
        case .skillUpload: return "30min learning"
        case .staticStretch: return "15min stretching"
        }
    }

    var checkQuestion: String {
        switch self {
        case .lockIn: return "Did you complete a focus block?"
        case .touchGrass: return "Did you walk outside for 30 mins?"
        case .coldReboot: return "Did you take a cold shower?"
        case .dailyWs: return "Did you list your daily wins?"
        case .phoneJail: return "Did you put the phone in 'jail'?"
        case .proteinFirst: return "Did you hit your protein target?"
        case .hydrationMax: return "Did you drink your water quota?"
        case .solarLoad: return "Did you get morning sunlight?"
        case .morningWin: return "Did you win the first 10 minutes?"
        case .zionCall: return "Did you connect with a real friend?"
        case .deepSleep: return "Were you in bed on schedule?"
        case .brainDump: return "Did you clear your mental RAM?"
        case .combatPrep: return "Did you execute your workout?"
        case .skillUpload: return "Did you learn something new?"
        case .staticStretch: return "Did you stretch today?"
        }
    }

    var difficulty: DifficultyTier {
        switch self {
        case .lockIn, .coldReboot, .combatPrep: return .hard
        case .touchGrass, .proteinFirst, .zionCall, .deepSleep, .skillUpload: return .medium
        case .dailyWs, .phoneJail, .hydrationMax, .solarLoad, .morningWin, .brainDump, .staticStretch: return .easy
        }
    }

    // Shadow Agent pair for this Power
    var shadowAgent: AgentHabit {
        switch self {
        case .lockIn: return .noBrainRot
        case .phoneJail: return .noMorningScroll
        case .touchGrass: return .noChairLock
        case .deepSleep: return .noBedScrolling
        case .morningWin: return .noSnooze
        case .proteinFirst: return .noJunkMeals
        case .hydrationMax: return .noLiquidSugar
        case .dailyWs: return .noSelfSabotage
        case .zionCall: return .noGhostingIRL
        case .combatPrep: return .noBingeGaming
        case .coldReboot: return .noVictimMode
        case .brainDump: return .noLateNight
        case .solarLoad: return .noSnooze
        case .skillUpload: return .noBrainRot
        case .staticStretch: return .noChairLock
        }
    }
}

// MARK: - Agent Habits (Bad habits to DEFEAT)

enum AgentHabit: String, CaseIterable, Hashable {
    // MARK: - Legacy/Universal Agents
    case noBrainRot = "No Brain Rot"
    case noMorningScroll = "No Morning Scroll"
    case noBedScrolling = "No Bed Scrolling"
    case noRageBait = "No Rage Bait"
    case noBingeGaming = "No Binge Gaming"
    case noSnooze = "No Snooze"
    case noLiquidSugar = "No Liquid Sugar"
    case noJunkMeals = "No Junk Meals"
    case noChairLock = "No Chair Lock"
    case noVictimMode = "No Victim Mode"
    case noSelfSabotage = "No Self-Sabotage"
    case noGhostingIRL = "No Ghosting IRL"
    case noImpulseBuys = "No Impulse Buys"
    case noLateNight = "No Late Night"

    // MARK: - PMO Family (Adult Content)
    case noPMO = "No PMO"                           // Hard
    case noPMONightShield = "No PMO (Night Shield)" // Easy - after 10pm
    case noPMODayGuard = "No PMO (Day Guard)"       // Medium - daylight hours

    // MARK: - Vaping Family
    case noVaping = "No Vaping"                     // Hard
    case noVapingIndoors = "No Vaping Indoors"      // Easy
    case noVapingBeforeNoon = "No Vaping Before Noon" // Medium

    // MARK: - Doomscrolling Family (noBedScrolling=Easy, noMorningScroll=Hard)
    case noSlopContent = "No Slop Content"          // Medium

    // MARK: - Gaming Family
    case noGaming = "No Gaming"                     // Hard
    case noGamingBeforeWin = "No Gaming Before Win" // Easy

    // MARK: - Junk Food Family (noLiquidSugar=Easy, noJunkMeals=Medium)
    case noPackagedJunk = "No Packaged Junk"        // Hard

    // MARK: - Bed Rotting Family (noSnooze=Hard)
    case morningMaker = "Morning Maker"             // Easy
    case noReturnToBed = "No Return to Bed"         // Medium

    // MARK: - Anxiety Family (noRageBait=Easy, noLateNight=Medium)
    case noNewsDoomInput = "No News/Doom Input"     // Hard

    var habitName: String { rawValue }

    var icon: String {
        switch self {
        // Legacy/Universal
        case .noBrainRot: return "brain.head.profile"
        case .noMorningScroll: return "iphone.slash"
        case .noBedScrolling: return "bed.double.fill"
        case .noRageBait: return "flame.fill"
        case .noBingeGaming: return "gamecontroller.fill"
        case .noSnooze: return "alarm.fill"
        case .noLiquidSugar: return "cup.and.saucer.fill"
        case .noJunkMeals: return "takeoutbag.and.cup.and.straw.fill"
        case .noChairLock: return "figure.stand"
        case .noVictimMode: return "person.fill.xmark"
        case .noSelfSabotage: return "exclamationmark.bubble.fill"
        case .noGhostingIRL: return "person.2.fill"
        case .noImpulseBuys: return "creditcard.fill"
        case .noLateNight: return "moon.fill"

        // PMO Family
        case .noPMO, .noPMONightShield, .noPMODayGuard: return "eye.slash.fill"

        // Vaping Family
        case .noVaping, .noVapingIndoors, .noVapingBeforeNoon: return "smoke.fill"

        // Doomscrolling Family
        case .noSlopContent: return "xmark.app.fill"

        // Gaming Family
        case .noGaming, .noGamingBeforeWin: return "gamecontroller.fill"

        // Junk Food Family
        case .noPackagedJunk: return "takeoutbag.and.cup.and.straw.fill"

        // Bed Rotting Family
        case .morningMaker: return "bed.double.fill"
        case .noReturnToBed: return "arrow.uturn.left.circle.fill"

        // Anxiety Family
        case .noNewsDoomInput: return "newspaper.fill"
        }
    }

    var description: String {
        switch self {
        // Legacy/Universal
        case .noBrainRot: return "Avoid mindless, low-quality content consumption."
        case .noMorningScroll: return "No phone within 30 mins of waking. Win the morning."
        case .noBedScrolling: return "Your bed is for sleep, not scrolling. Protects sleep quality."
        case .noRageBait: return "Stop feeding the anxiety machine."
        case .noBingeGaming: return "Play, don't disappear. 3 hour max."
        case .noSnooze: return "The first decision of the day sets the tone."
        case .noLiquidSugar: return "The easiest poison to cut. Drinks first."
        case .noJunkMeals: return "No drive-thru. No delivery trash."
        case .noChairLock: return "Stagnation is the enemy. Keep moving."
        case .noVictimMode: return "No blaming others or making excuses."
        case .noSelfSabotage: return "No doom talk like 'I'm cooked' or 'It's over'."
        case .noGhostingIRL: return "Don't ignore real friends for online ones."
        case .noImpulseBuys: return "No unnecessary purchases without 24hr wait."
        case .noLateNight: return "Sleep is the #1 anxiety medication."

        // PMO Family
        case .noPMO: return "Complete abstinence. Total dopamine reset."
        case .noPMONightShield: return "No adult content after 10pm. Peak danger hours are off limits."
        case .noPMODayGuard: return "Stay clean during daylight. Night is the release valve while building strength."

        // Vaping Family
        case .noVaping: return "Complete freedom from the cloud."
        case .noVapingIndoors: return "Keep the poison outside your space. Adds friction."
        case .noVapingBeforeNoon: return "Break the morning dependency. Earn your first hit."

        // Doomscrolling Family
        case .noSlopContent: return "Cut the specific poison. TikTok/Reels/Shorts are the worst offenders."

        // Gaming Family
        case .noGaming: return "Complete detox. Build in reality."
        case .noGamingBeforeWin: return "Gaming is the reward, not the activity. Earn it first."

        // Junk Food Family
        case .noPackagedJunk: return "If it comes in a wrapper, it's probably garbage."

        // Bed Rotting Family
        case .morningMaker: return "First win of the day. Small but powerful."
        case .noReturnToBed: return "Once you're up, you're up. Bed is for sleep only."

        // Anxiety Family
        case .noNewsDoomInput: return "Complete information diet. Zero input from anxiety factory."
        }
    }

    var shortDescription: String {
        switch self {
        // Legacy/Universal
        case .noBrainRot: return "No mindless content"
        case .noMorningScroll: return "No phone 30min AM"
        case .noBedScrolling: return "Phone out of bed"
        case .noRageBait: return "No outrage content"
        case .noBingeGaming: return "Gaming < 3 hours"
        case .noSnooze: return "First alarm = up"
        case .noLiquidSugar: return "No soda/energy drinks"
        case .noJunkMeals: return "No fast food"
        case .noChairLock: return "Move every 2 hours"
        case .noVictimMode: return "No excuses"
        case .noSelfSabotage: return "No doom talk"
        case .noGhostingIRL: return "Engage IRL friends"
        case .noImpulseBuys: return "24hr purchase wait"
        case .noLateNight: return "Respect sleep time"

        // PMO Family
        case .noPMO: return "Complete abstinence"
        case .noPMONightShield: return "Clean after 10pm"
        case .noPMODayGuard: return "Clean during day"

        // Vaping Family
        case .noVaping: return "No vaping at all"
        case .noVapingIndoors: return "Only vape outside"
        case .noVapingBeforeNoon: return "No vape before noon"

        // Doomscrolling Family
        case .noSlopContent: return "No TikTok/Reels"

        // Gaming Family
        case .noGaming: return "Complete detox"
        case .noGamingBeforeWin: return "Earn gaming first"

        // Junk Food Family
        case .noPackagedJunk: return "No packaged food"

        // Bed Rotting Family
        case .morningMaker: return "Make bed daily"
        case .noReturnToBed: return "Stay up once up"

        // Anxiety Family
        case .noNewsDoomInput: return "No news/doom input"
        }
    }

    var checkQuestion: String {
        switch self {
        // Legacy/Universal
        case .noBrainRot: return "Did you avoid mindless 'slop' content?"
        case .noMorningScroll: return "Did you stay off phone for 30min after waking?"
        case .noBedScrolling: return "Did you keep your phone out of bed?"
        case .noRageBait: return "Did you avoid outrage content and online arguments?"
        case .noBingeGaming: return "Did you keep gaming under 3 hours?"
        case .noSnooze: return "Did you get up on the first alarm?"
        case .noLiquidSugar: return "Did you avoid soda, energy drinks, and sweet coffee?"
        case .noJunkMeals: return "Did you avoid fast food and processed meals?"
        case .noChairLock: return "Did you move your body every 2 hours?"
        case .noVictimMode: return "Did you take ownership without blaming others?"
        case .noSelfSabotage: return "Did you speak well of your progress?"
        case .noGhostingIRL: return "Did you engage with real people today?"
        case .noImpulseBuys: return "Did you avoid unnecessary purchases?"
        case .noLateNight: return "Did you respect your sleep deadline?"

        // PMO Family
        case .noPMO: return "Did you completely abstain from adult content?"
        case .noPMONightShield: return "Did you avoid adult content after 10pm?"
        case .noPMODayGuard: return "Did you stay clean during daylight hours (6am-8pm)?"

        // Vaping Family
        case .noVaping: return "Did you stay completely substance-free?"
        case .noVapingIndoors: return "Did you only vape outside today?"
        case .noVapingBeforeNoon: return "Did you wait until after noon to vape?"

        // Doomscrolling Family
        case .noSlopContent: return "Did you avoid TikTok, Reels, and Shorts today?"

        // Gaming Family
        case .noGaming: return "Did you avoid gaming entirely today?"
        case .noGamingBeforeWin: return "Did you complete a real task before gaming?"

        // Junk Food Family
        case .noPackagedJunk: return "Did you avoid all packaged/processed junk food?"

        // Bed Rotting Family
        case .morningMaker: return "Did you make your bed within 10 minutes of waking?"
        case .noReturnToBed: return "Did you stay out of bed after waking (except for sleep)?"

        // Anxiety Family
        case .noNewsDoomInput: return "Did you avoid news, doom content, and anxiety triggers?"
        }
    }

    var counterTactic: String {
        switch self {
        // Legacy/Universal
        case .noBrainRot: return "Set app time limits. Replace with reading."
        case .noMorningScroll: return "Morning stack: Water → Light → Movement → THEN phone."
        case .noBedScrolling: return "Phone charges across the room. Bed = phone-free zone."
        case .noRageBait: return "Unfollow. Mute. Block. Curate ruthlessly."
        case .noBingeGaming: return "Set timer. When it rings, you're done. No 'one more game.'"
        case .noSnooze: return "Alarm across the room. No negotiation with tired brain."
        case .noLiquidSugar: return "Water. Black coffee. Nothing else liquid."
        case .noJunkMeals: return "Meal prep Sunday. Decide in advance."
        case .noChairLock: return "Hourly alarm. Stand, stretch, walk."
        case .noVictimMode: return "Ask: What CAN I control right now?"
        case .noSelfSabotage: return "Reframe: Progress not perfection."
        case .noGhostingIRL: return "Schedule one IRL hangout per week."
        case .noImpulseBuys: return "24-hour waiting rule before buying."
        case .noLateNight: return "Hard deadline. Alarm means STOP, not snooze."

        // PMO Family
        case .noPMO: return "Urge surfing - ride the wave, it peaks at 20 min then fades."
        case .noPMONightShield: return "After 10pm, you're off limits. Urge hits? 20 pushups."
        case .noPMODayGuard: return "Urges during day? 20 pushups or cold water on face."

        // Vaping Family
        case .noVaping: return "Deep breaths. Gum. Ice water. The craving peaks at 3 min then fades."
        case .noVapingIndoors: return "Every vape = going outside. Rain or shine."
        case .noVapingBeforeNoon: return "Morning stack: Water → Sunlight → Movement → THEN consider vaping."

        // Doomscrolling Family
        case .noSlopContent: return "Delete the apps. Use website versions with friction if needed."

        // Gaming Family
        case .noGaming: return "Channel competitive energy into real skills - gym, learning, building."
        case .noGamingBeforeWin: return "List 1 real win before playing. Workout, task, chore - then game."

        // Junk Food Family
        case .noPackagedJunk: return "Shop the perimeter of the grocery store only."

        // Bed Rotting Family
        case .morningMaker: return "Feet hit floor → Make bed. No negotiation."
        case .noReturnToBed: return "If tired mid-day, sit on couch - never back in bed."

        // Anxiety Family
        case .noNewsDoomInput: return "No news apps. No doomscroll. No 'staying informed' excuse."
        }
    }

    var difficulty: DifficultyTier {
        switch self {
        // HARD tier agents
        case .noMorningScroll,          // Doomscrolling Hard
             .noPMO,                     // PMO Hard
             .noVaping,                  // Vaping Hard
             .noGaming,                  // Gaming Hard
             .noPackagedJunk,            // Junk Food Hard
             .noSnooze,                  // Bed Rotting Hard
             .noNewsDoomInput,           // Anxiety Hard
             .noVictimMode:              // Legacy Hard
            return .hard

        // MEDIUM tier agents
        case .noPMODayGuard,             // PMO Medium
             .noVapingBeforeNoon,        // Vaping Medium
             .noSlopContent,             // Doomscrolling Medium
             .noBingeGaming,             // Gaming Medium
             .noJunkMeals,               // Junk Food Medium
             .noReturnToBed,             // Bed Rotting Medium
             .noLateNight,               // Anxiety Medium
             .noBrainRot,                // Legacy Medium
             .noSelfSabotage,            // Legacy Medium
             .noImpulseBuys:             // Legacy Medium
            return .medium

        // EASY tier agents
        case .noPMONightShield,          // PMO Easy
             .noVapingIndoors,           // Vaping Easy
             .noBedScrolling,            // Doomscrolling Easy
             .noGamingBeforeWin,         // Gaming Easy
             .noLiquidSugar,             // Junk Food Easy
             .morningMaker,              // Bed Rotting Easy
             .noRageBait,                // Anxiety Easy
             .noChairLock,               // Legacy Easy
             .noGhostingIRL:             // Legacy Easy
            return .easy
        }
    }

    // Priority for Universal Agent Pool (1 = highest priority)
    var universalPriority: Int {
        switch self {
        case .noBedScrolling: return 1  // Sleep/Digital - highest impact
        case .noLiquidSugar: return 2   // Diet/Energy
        case .noSnooze: return 3        // Discipline
        case .noChairLock: return 4     // Movement
        case .noSelfSabotage: return 5  // Mental hygiene
        default: return 99
        }
    }

    // MARK: - Tier Promotion System

    /// Which family this agent belongs to (nil for legacy/universal agents)
    var family: AgentFamily? {
        switch self {
        // PMO Family
        case .noPMO, .noPMONightShield, .noPMODayGuard:
            return .pmo
        // Vaping Family
        case .noVaping, .noVapingIndoors, .noVapingBeforeNoon:
            return .vaping
        // Doomscrolling Family
        case .noBedScrolling, .noSlopContent, .noMorningScroll:
            return .doomscrolling
        // Gaming Family
        case .noGaming, .noGamingBeforeWin, .noBingeGaming:
            return .gaming
        // Junk Food Family
        case .noLiquidSugar, .noJunkMeals, .noPackagedJunk:
            return .junkFood
        // Bed Rotting Family
        case .morningMaker, .noReturnToBed, .noSnooze:
            return .bedRotting
        // Anxiety Family
        case .noRageBait, .noLateNight, .noNewsDoomInput:
            return .anxiety
        // Legacy/Universal - no family
        default:
            return nil
        }
    }

    /// The next tier agent to promote to (nil if already at Hard or legacy agent)
    var nextTierAgent: AgentHabit? {
        guard let family = self.family else { return nil }

        switch difficulty {
        case .easy:
            return family.agent(for: .medium)
        case .medium:
            return family.agent(for: .hard)
        case .hard:
            return nil  // Already at max tier
        }
    }

    /// Streak days required to trigger promotion suggestion
    var promotionThreshold: Int {
        switch difficulty {
        case .easy: return 14   // 2 weeks to suggest Medium
        case .medium: return 28 // 4 weeks to suggest Hard
        case .hard: return 0    // No promotion from Hard
        }
    }
}

// MARK: - Onboarding Question Types

enum BrokenPromisesOption: String, CaseIterable {
    case rarely = "Rarely"
    case often = "Often"
    case always = "Always"
}

// Reframed: "How do you feel about the RESULT of that time?"
enum ScrollEmotion: String, CaseIterable {
    case productive = "Productive"
    case empty = "Empty"
    case regret = "Regret"

    var matrixFlavor: String {
        switch self {
        case .productive: return "Time well spent."
        case .empty: return "Hollow returns."
        case .regret: return "Investment lost."
        }
    }
}

// MARK: - Physical Focus Enums

enum MovementLevel: String, CaseIterable {
    case recent = "Today or Yesterday"
    case lastWeek = "Within the Last Week"
    case monthPlus = "Over a Month Ago"

    var matrixFlavor: String {
        switch self {
        case .recent: return "Active. Systems operational."
        case .lastWeek: return "Rusty. Power levels dropping."
        case .monthPlus: return "Stagnant. Atrophy detected."
        }
    }
}

enum EnergyCrash: String, CaseIterable {
    case afternoon = "Mid-Afternoon (2-4pm)"
    case morning = "Morning (Wake up tired)"
    case constant = "Constant Low Power"

    var matrixFlavor: String {
        switch self {
        case .afternoon: return "Glucose instability."
        case .morning: return "Dehydration / Sleep debt."
        case .constant: return "System failure."
        }
    }
}

enum SleepQuality: String, CaseIterable {
    case optimized = "Woke up ready"
    case groggy = "Groggy / Slow Boot"
    case broken = "Broken / Insomnia"

    var matrixFlavor: String {
        switch self {
        case .optimized: return "100% Charge."
        case .groggy: return "Latency detected."
        case .broken: return "Recharge failed."
        }
    }
}

enum MotivationType: String, CaseIterable {
    case myself = "For Myself"
    case should = "Because I Should"
}

// MARK: - Protocol Loadout

// Full protocol loadout with both Hacks and Agents
struct ProtocolLoadout {
    var hacks: [HackHabit] = []
    var agents: [AgentHabit] = []
}
