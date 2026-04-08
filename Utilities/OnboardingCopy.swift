import Foundation

// MARK: - Copy Keys

enum CopyKey {
    // Phase 1
    case terminologyOpener
    // Phase 3
    case hookQuestion
    // Phase 4
    case problemButton
    // Phase 5
    case yearsDeletedPrompt
    case yearsDeletedButton
    // Phase 6
    case brokenPromisesQuestion
    // Phase 7
    case postScrollQuestion
    // Phase 8
    case kineticQuestion
    // Phase 9
    case fuelQuestion
    // Phase 10
    case rechargeQuestion
    // Phase 11
    case motivationQuestion
    // Phase 13
    case truthLine1
    case truthLine2
    case truthLine3
    // Phase 14
    case wayOutLine1
    case wayOutLine2
    case wayOutLine3
    // Phase 16
    case contractHold
    case contractPostHold
}

// MARK: - Onboarding Copy

struct OnboardingCopy {
    let tier: DemographicTier

    func text(for key: CopyKey) -> String {
        switch key {

        // MARK: Phase 1 — Terminology Opener

        case .terminologyOpener:
            switch tier {
            case .maleYouth:   return "Here's how this works."
            case .femaleYouth: return "Here's how this works — it's simpler than it sounds."
            case .maleYoung:   return "Quick rundown. Then we build your system."
            case .femaleYoung: return "Quick guide. Then we set up something that actually works for you."
            case .maleAdult:   return "Two minutes to learn the system. Then you're in."
            case .femaleAdult: return "Quick overview — then we'll set up something built around your life."
            }

        // MARK: Phase 3 — Hook Question

        case .hookQuestion:
            switch tier {
            case .maleYouth:   return "Do you feel like you are living below your potential?"
            case .femaleYouth: return "Do you feel like the version of you that you want to be keeps slipping away?"
            case .maleYoung:   return "You know what you need to do. You're just not doing it. Sound familiar?"
            case .femaleYoung: return "You keep showing up for everyone except yourself. Sound familiar?"
            case .maleAdult:   return "When was the last time you felt fully in control of your daily routine?"
            case .femaleAdult: return "When was the last time you did something just for you — without guilt?"
            }

        // MARK: Phase 4 — Problem Button

        case .problemButton:
            switch tier {
            case .maleYouth:   return "ACKNOWLEDGE CHAINS_"
            case .femaleYouth: return "I'M DONE WITH THIS_"
            case .maleYoung:   return "THESE END NOW_"
            case .femaleYoung: return "I'M CHOOSING MYSELF_"
            case .maleAdult:   return "LET'S FIX THIS_"
            case .femaleAdult: return "THIS CHANGES TODAY_"
            }

        // MARK: Phase 5 — Years Deleted

        case .yearsDeletedPrompt:
            switch tier {
            case .maleYouth:   return "How many hours a day do you waste on things that don't matter?"
            case .femaleYouth: return "How many hours a day disappear into your phone?"
            case .maleYoung:   return "Be honest. How many hours a day do you lose to autopilot?"
            case .femaleYoung: return "How many hours a day do you spend on everyone else — and zero on yourself?"
            case .maleAdult:   return "How many hours a day slip away without intention?"
            case .femaleAdult: return "How many hours a day are you running on empty instead of recharging?"
            }

        case .yearsDeletedButton:
            switch tier {
            case .maleYouth:   return "I AM ANGRY"
            case .femaleYouth: return "I DESERVE BETTER"
            case .maleYoung:   return "ENOUGH"
            case .femaleYoung: return "NO MORE"
            case .maleAdult:   return "TIME TO CHANGE"
            case .femaleAdult: return "I'M TAKING THIS BACK"
            }

        // MARK: Phase 6 — Broken Promises

        case .brokenPromisesQuestion:
            switch tier {
            case .maleYouth:   return "How often do you break promises you make to yourself?"
            case .femaleYouth: return "How often do you plan to start something and never follow through?"
            case .maleYoung:   return "How often do you tell yourself 'starting Monday' and never do?"
            case .femaleYoung: return "How often do you say yes to others and break promises to yourself?"
            case .maleAdult:   return "How often do you plan to change a habit and abandon it within a week?"
            case .femaleAdult: return "How often do you put your own needs last because everyone else comes first?"
            }

        // MARK: Phase 7 — Post-Scroll Emotion

        case .postScrollQuestion:
            switch tier {
            case .maleYouth:   return "How do you feel about the RESULT of that time?"
            case .femaleYouth: return "After a long scroll session, how do you actually feel?"
            case .maleYoung:   return "After burning 3 hours on your phone, what's the feeling?"
            case .femaleYoung: return "When you finally put your phone down at 2am, what hits you?"
            case .maleAdult:   return "After an evening lost to screens instead of what matters, how do you feel?"
            case .femaleAdult: return "After spending your only free hour scrolling instead of resting, how do you feel?"
            }

        // MARK: Phase 8 — Kinetic Integrity

        case .kineticQuestion:
            switch tier {
            case .maleYouth:   return "When did you last break a sweat?"
            case .femaleYouth: return "When did you last move your body — not for looks, just because it felt good?"
            case .maleYoung:   return "When was your last real workout?"
            case .femaleYoung: return "When was the last time you moved your body without it feeling like a chore?"
            case .maleAdult:   return "When did you last get your heart rate up intentionally?"
            case .femaleAdult: return "When was the last time you had time to exercise — and actually took it?"
            }

        // MARK: Phase 9 — Fuel Purity

        case .fuelQuestion:
            switch tier {
            case .maleYouth:   return "When do your energy systems typically crash?"
            case .femaleYouth: return "When does your energy crash hardest?"
            case .maleYoung:   return "When does your energy tank?"
            case .femaleYoung: return "When do you hit the wall every day?"
            case .maleAdult:   return "When do you typically lose focus and energy?"
            case .femaleAdult: return "When do you run out of fuel — physically and mentally?"
            }

        // MARK: Phase 10 — Recharge Cycle

        case .rechargeQuestion:
            switch tier {
            case .maleYouth:   return "How would you rate your sleep quality last night?"
            case .femaleYouth: return "How did you sleep last night — honestly?"
            case .maleYoung:   return "Last night's sleep — how was it really?"
            case .femaleYoung: return "Did you actually rest last night, or just eventually pass out?"
            case .maleAdult:   return "How's your sleep quality been lately?"
            case .femaleAdult: return "When you wake up, do you feel rested — or just less exhausted?"
            }

        // MARK: Phase 11 — Motivation Check

        case .motivationQuestion:
            switch tier {
            case .maleYouth:   return "Are you doing this for yourself, or because you feel you 'should'?"
            case .femaleYouth: return "Are you doing this because YOU want to change, or because you think you're supposed to?"
            case .maleYoung:   return "Is this for you, or because you think you should be further along by now?"
            case .femaleYoung: return "Is this for you, or because everyone around you seems to have it together?"
            case .maleAdult:   return "Are you here for yourself, or because something scared you into it?"
            case .femaleAdult: return "Are you doing this for you — not your partner, not your family — just you?"
            }

        // MARK: Phase 13 — The Truth (first 3 lines)

        case .truthLine1:
            switch tier {
            case .maleYouth:   return "You are not lazy."
            case .femaleYouth: return "You are not failing."
            case .maleYoung:   return "You are not unmotivated."
            case .femaleYoung: return "You are not too much."
            case .maleAdult:   return "You are not past your prime."
            case .femaleAdult: return "You are not selfish for wanting this."
            }

        case .truthLine2:
            switch tier {
            case .maleYouth:   return "You are not broken."
            case .femaleYouth: return "You are not behind."
            case .maleYoung:   return "You are not a failure."
            case .femaleYoung: return "You are not not enough."
            case .maleAdult:   return "You are not stuck."
            case .femaleAdult: return "You are not weak."
            }

        case .truthLine3:
            switch tier {
            case .maleYouth:   return "You are PROGRAMMED."
            case .femaleYouth: return "You have been PROGRAMMED."
            case .maleYoung:   return "You are PROGRAMMED."
            case .femaleYoung: return "You have been PROGRAMMED."
            case .maleAdult:   return "You are PROGRAMMED."
            case .femaleAdult: return "You have been PROGRAMMED."
            }

        // MARK: Phase 14 — The Way Out (3 principle lines)

        case .wayOutLine1:
            switch tier {
            case .maleYouth:   return "Not motivation. SYSTEMS."
            case .femaleYouth: return "Not perfection. PROGRESS."
            case .maleYoung:   return "Not hustle. SYSTEMS."
            case .femaleYoung: return "Not performing. HEALING."
            case .maleAdult:   return "Not more time. BETTER SYSTEMS."
            case .femaleAdult: return "Not more effort. SMARTER SYSTEMS."
            }

        case .wayOutLine2:
            switch tier {
            case .maleYouth:   return "Not willpower. AWARENESS."
            case .femaleYouth: return "Not willpower. SYSTEMS."
            case .maleYoung:   return "Not motivation. TRACKING."
            case .femaleYoung: return "Not perfection. PRACTICE."
            case .maleAdult:   return "Not motivation. ROUTINE."
            case .femaleAdult: return "Not guilt. PERMISSION."
            }

        case .wayOutLine3:
            switch tier {
            case .maleYouth:   return "Not perfection. CONSISTENCY."
            case .femaleYouth: return "Not guilt. CONSISTENCY."
            case .maleYoung:   return "Not perfection. SHOWING UP."
            case .femaleYoung: return "Not guilt. GRACE."
            case .maleAdult:   return "Not perfection. DATA."
            case .femaleAdult: return "Not perfection. PRESENCE."
            }

        // MARK: Phase 16 — Contract

        case .contractHold:
            switch tier {
            case .maleYouth:   return "HOLD TO DISCONNECT FROM SIMULATION"
            case .femaleYouth: return "HOLD TO BEGIN YOUR NEW ERA"
            case .maleYoung:   return "HOLD TO INITIALIZE YOUR SYSTEM"
            case .femaleYoung: return "HOLD TO CHOOSE YOURSELF"
            case .maleAdult:   return "HOLD TO TAKE CONTROL"
            case .femaleAdult: return "HOLD TO RECLAIM YOUR TIME"
            }

        case .contractPostHold:
            switch tier {
            case .maleYouth:   return "WELCOME TO THE DESERT OF THE REAL."
            case .femaleYouth: return "WELCOME TO YOUR NEW ERA."
            case .maleYoung:   return "SYSTEM INITIALIZED. DAY 1."
            case .femaleYoung: return "YOU JUST CHOSE YOURSELF. DAY 1."
            case .maleAdult:   return "SYSTEM ACTIVE. LET'S GO."
            case .femaleAdult: return "THIS IS YOURS NOW. DAY 1."
            }
        }
    }
}
