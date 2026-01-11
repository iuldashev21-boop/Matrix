import Foundation

// MARK: - Anomaly Progress Tracking

class AnomalyManager: ObservableObject {
    @Published var unlockedReports: Set<String> = []
    @Published var decryptionProgress: [String: Int] = [:] // reportId: days (0-5)

    private let unlockedKey = "unlockedAnomalyReports"
    private let progressKey = "anomalyDecryptionProgress"

    init() {
        loadProgress()
    }

    // MARK: - Static Content

    static let allReports: [AnomalyReport] = [
        AnomalyReport(
            id: "001",
            title: "THE PIXEL LIMIT",
            category: .physics,
            content: "The Planck Length is 1.6 x 10^-35 meters. In physics, this is the smallest measurable unit of space. Anything smaller makes no physical sense. In computing, we call this the resolution limit of the screen."
        ),
        AnomalyReport(
            id: "002",
            title: "RENDERING LAG",
            category: .neuroscience,
            content: "Neuroscience confirms your conscious mind processes visual data 80 milliseconds after it hits your eyes. You are never seeing 'Now.' You are watching a live stream with a buffer."
        ),
        AnomalyReport(
            id: "003",
            title: "SOURCE CODE",
            category: .movieTrivia,
            content: "The iconic Green Code Rain in the original Matrix movie isn't binary. It consists of Japanese hiragana characters, specifically... sushi recipes scanned from a cookbook. We are literally raw data."
        ),
        AnomalyReport(
            id: "004",
            title: "THE OBSERVER",
            category: .quantumPhysics,
            content: "In the Double Slit Experiment, particles behave as waves until they are observed. Once watched, they collapse into specific positions. The universe only renders the details when you are looking."
        ),
        AnomalyReport(
            id: "005",
            title: "VERSION CONFLICT",
            category: .psychology,
            content: "Millions remember 'The Berenstein Bears.' History records 'The Berenstain Bears.' Some call this the Mandela Effect. We call it a merge conflict in the timeline version control."
        ),
        AnomalyReport(
            id: "006",
            title: "UNIVERSAL DESIGN",
            category: .math,
            content: "The Golden Ratio (1.618) appears in hurricane spirals, galaxy formations, pinecones, and human DNA. It is the reused asset library of the universe's design algorithm."
        ),
        AnomalyReport(
            id: "007",
            title: "RESIDUAL IMAGE",
            category: .neuroscience,
            content: "Phantom Limb Syndrome occurs when the brain continues to feel a missing limb. Your mind's internal map (Residual Self-Image) overrides the physical hardware status."
        ),
        AnomalyReport(
            id: "008",
            title: "THE GLITCH",
            category: .psychology,
            content: "Déjà vu is the feeling that you have lived this exact moment before. Scientists speculate it is a momentary misfiring between short-term and long-term memory writing. A database write error."
        ),
        AnomalyReport(
            id: "009",
            title: "PATTERN IMPRINT",
            category: .psychology,
            content: "Play Tetris for hours, and you will see falling blocks when you close your eyes. This is the 'Tetris Effect.' Your brain begins to hallucinate the simulation it has been trained on."
        ),
        AnomalyReport(
            id: "010",
            title: "THE ARGUMENT",
            category: .philosophy,
            content: "Philosopher Nick Bostrom argued: If it is possible to simulate a universe, and civilizations survive long enough to do it, they will run billions of them. Therefore, the odds we are in Base Reality are one in billions."
        )
    ]

    // MARK: - Unlock Logic

    func getReportState(_ reportId: String) -> ReportState {
        if unlockedReports.contains(reportId) {
            return .unlocked
        } else if let progress = decryptionProgress[reportId], progress > 0 {
            return .decrypting(progress: progress)
        } else {
            return .locked
        }
    }

    enum ReportState {
        case locked
        case decrypting(progress: Int) // 1-4 days
        case unlocked // 5 days complete
    }

    // MARK: - Progress Actions

    func startDecrypting(_ reportId: String) {
        guard decryptionProgress[reportId] == nil else { return }
        decryptionProgress[reportId] = 0
        saveProgress()
    }

    func incrementDecryption(_ reportId: String) {
        guard var progress = decryptionProgress[reportId] else { return }
        progress += 1

        if progress >= 5 {
            // Fully decrypted
            unlockedReports.insert(reportId)
            decryptionProgress.removeValue(forKey: reportId)
        } else {
            decryptionProgress[reportId] = progress
        }

        saveProgress()
    }

    // Call this on each check-in to progress all active decryptions
    func onDailyCheckIn() {
        for reportId in decryptionProgress.keys {
            incrementDecryption(reportId)
        }
    }

    // MARK: - Unlock by Milestone

    func unlockReportForMilestone(day: Int) {
        // Unlock reports at specific milestones
        let milestones: [Int: String] = [
            3: "001",
            7: "002",
            14: "003",
            21: "004",
            30: "005",
            42: "006",
            50: "007",
            60: "008",
            Theme.habitFormationDays: "009",
            100: "010"
        ]

        if let id = milestones[day], !unlockedReports.contains(id) {
            startDecrypting(id)
        }
    }

    // MARK: - Persistence

    private func saveProgress() {
        UserDefaults.standard.set(Array(unlockedReports), forKey: unlockedKey)

        do {
            let encoded = try JSONEncoder().encode(decryptionProgress)
            UserDefaults.standard.set(encoded, forKey: progressKey)
        } catch {
            ErrorLogger.logEncodingFailure(error, context: "AnomalyManager.saveProgress")
        }
    }

    private func loadProgress() {
        if let saved = UserDefaults.standard.stringArray(forKey: unlockedKey) {
            unlockedReports = Set(saved)
        }

        if let data = UserDefaults.standard.data(forKey: progressKey) {
            do {
                decryptionProgress = try JSONDecoder().decode([String: Int].self, from: data)
            } catch {
                ErrorLogger.logDecodingFailure(error, context: "AnomalyManager.loadProgress")
            }
        }
    }

    // MARK: - Text Scramble Helper

    static func scrambleText(_ text: String, revealPercentage: Double) -> String {
        let matrixChars = "ァアィイゥウェエォオカガキギクグケゲコゴサザシジスズセゼソゾタダチヂッツヅテデトドナニヌネノハバパヒビピフブプヘベペホボポマミムメモャヤュユョヨラリルレロワヲン0123456789"

        var result = ""
        let characters = Array(text)

        for (index, char) in characters.enumerated() {
            if char == " " || char == "\n" {
                result.append(char)
            } else {
                let threshold = Double(index) / Double(characters.count)
                if threshold < revealPercentage {
                    result.append(char)
                } else {
                    let randomChar = matrixChars.randomElement() ?? "?"
                    result.append(randomChar)
                }
            }
        }

        return result
    }
}
