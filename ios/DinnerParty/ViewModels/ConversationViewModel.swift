import Foundation
import SwiftData
import SwiftUI

@Observable
final class ConversationViewModel {
    var conversation: Conversation?
    var messages: [VoiceMessage] = []
    var isRecording: Bool = false
    var recordingDuration: TimeInterval = 0
    var isPastFiveMinutes: Bool = false
    var hasPendingRecording: Bool = false
    var pendingRecordingDuration: TimeInterval = 0
    var isGeneratingSummary: Bool = false

    let recorder = AudioRecorderService()
    let player = AudioPlayerService()
    private let summaryService = SummaryService()
    private var modelContext: ModelContext?
    private var pendingRecordingResult: (url: URL, duration: TimeInterval, fileName: String)?

    func setup(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadOrCreateConversation()
        loadMessages()
    }

    private func loadOrCreateConversation() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<Conversation>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        if let existing = try? modelContext.fetch(descriptor).first {
            conversation = existing
        } else {
            let newConversation = Conversation(participantName: "Friend")
            modelContext.insert(newConversation)
            conversation = newConversation
        }
    }

    func loadMessages() {
        guard let modelContext, let conversation else { return }
        let conversationID = conversation.id
        let descriptor = FetchDescriptor<VoiceMessage>(
            predicate: #Predicate { $0.conversationID == conversationID },
            sortBy: [SortDescriptor(\.createdAt)]
        )
        messages = (try? modelContext.fetch(descriptor)) ?? []
    }

    @discardableResult
    func startRecording() async -> Bool {
        let success = await recorder.startRecording()
        if success {
            isRecording = true
            hasPendingRecording = false
            pendingRecordingResult = nil
            observeRecorder()
        }
        return success
    }

    private func observeRecorder() {
        Task {
            while recorder.isRecording {
                recordingDuration = recorder.recordingDuration
                isPastFiveMinutes = recorder.isPastFiveMinutes
                try? await Task.sleep(for: .milliseconds(100))
            }
        }
    }

    func stopRecording() {
        if let result = recorder.stopRecording() {
            pendingRecordingResult = result
            pendingRecordingDuration = result.duration
            hasPendingRecording = true
        }
        isRecording = false
        recordingDuration = 0
        isPastFiveMinutes = false
    }

    func cancelRecording() {
        if hasPendingRecording {
            if let url = pendingRecordingResult?.url {
                try? FileManager.default.removeItem(at: url)
            }
            pendingRecordingResult = nil
            hasPendingRecording = false
            pendingRecordingDuration = 0
        } else {
            recorder.cancelRecording()
            isRecording = false
            recordingDuration = 0
            isPastFiveMinutes = false
        }
    }

    func sendRecording() {
        guard let result = pendingRecordingResult,
              let modelContext,
              let conversation else { return }

        let message = VoiceMessage(
            conversationID: conversation.id,
            senderName: "You",
            isMine: true,
            duration: result.duration,
            audioFileName: result.fileName
        )
        modelContext.insert(message)
        conversation.lastActivityAt = Date()

        hasPendingRecording = false
        pendingRecordingResult = nil
        pendingRecordingDuration = 0

        loadMessages()
        updateSummary()
    }

    func playMessage(_ message: VoiceMessage) {
        guard let url = message.audioURL else { return }
        if player.currentMessageID == message.id && player.isPlaying {
            player.pause()
        } else if player.currentMessageID == message.id {
            player.resume()
        } else {
            player.play(url: url, messageID: message.id)
        }
    }

    func updateSummary() {
        guard !messages.isEmpty else { return }
        isGeneratingSummary = true

        let messageData = messages.map { msg in
            (sender: msg.senderName, duration: msg.duration, date: msg.createdAt)
        }

        Task {
            if let summary = await summaryService.generateSummary(messages: messageData) {
                let cleaned = summary
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacingOccurrences(of: "\"", with: "")
                conversation?.summary = cleaned
                conversation?.summaryUpdatedAt = Date()
            }
            isGeneratingSummary = false
        }
    }

    func formattedDuration(_ duration: TimeInterval) -> String {
        let mins = Int(duration) / 60
        let secs = Int(duration) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
