import Foundation
import SwiftData

@Model
final class CheckIn {
    var id: UUID
    var date: Date
    var isSuccess: Bool
    var note: String?
    var createdAt: Date

    var power: Power?
    var agent: Agent?

    init(date: Date, isSuccess: Bool, note: String? = nil) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.isSuccess = isSuccess
        self.note = note
        self.createdAt = Date()
    }
}
