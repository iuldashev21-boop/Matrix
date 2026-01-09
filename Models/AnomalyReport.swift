import Foundation

// MARK: - Anomaly Report Data

struct AnomalyReport: Identifiable {
    let id: String
    let title: String
    let category: AnomalyCategory
    let content: String

    enum AnomalyCategory: String {
        case physics = "PHYSICS"
        case neuroscience = "NEUROSCIENCE"
        case movieTrivia = "MOVIE TRIVIA"
        case quantumPhysics = "QUANTUM PHYSICS"
        case psychology = "PSYCHOLOGY"
        case math = "MATH"
        case philosophy = "PHILOSOPHY"
    }
}
