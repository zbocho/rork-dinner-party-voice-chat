import Foundation
import SwiftData

@Model
class Conversation {
    var id: String
    var participantName: String
    var summary: String
    var summaryUpdatedAt: Date?
    var createdAt: Date
    var lastActivityAt: Date

    init(participantName: String) {
        self.id = UUID().uuidString
        self.participantName = participantName
        self.summary = ""
        self.createdAt = Date()
        self.lastActivityAt = Date()
    }
}
