import Foundation
import SwiftData

@Model
class VoiceMessage {
    var id: String
    var conversationID: String
    var senderName: String
    var senderInitial: String
    var isMine: Bool
    var duration: TimeInterval
    var audioFileName: String
    var createdAt: Date

    init(
        conversationID: String,
        senderName: String,
        isMine: Bool,
        duration: TimeInterval,
        audioFileName: String
    ) {
        self.id = UUID().uuidString
        self.conversationID = conversationID
        self.senderName = senderName
        self.senderInitial = String(senderName.prefix(1)).uppercased()
        self.isMine = isMine
        self.duration = duration
        self.audioFileName = audioFileName
        self.createdAt = Date()
    }

    var audioURL: URL? {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return docs?.appendingPathComponent(audioFileName)
    }
}
