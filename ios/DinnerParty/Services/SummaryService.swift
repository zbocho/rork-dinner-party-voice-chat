import Foundation

nonisolated struct SummaryRequest: Codable, Sendable {
    let messages: [SummaryMessage]
}

nonisolated struct SummaryMessage: Codable, Sendable {
    let role: String
    let content: String
}

nonisolated struct SummaryResponse: Codable, Sendable {
    let text: String
}

final class SummaryService {
    private let toolkitURL: String

    init() {
        self.toolkitURL = Config.EXPO_PUBLIC_TOOLKIT_URL
    }

    func generateSummary(messages: [(sender: String, duration: TimeInterval, date: Date)]) async -> String? {
        guard !messages.isEmpty else { return nil }

        let baseURL = toolkitURL.isEmpty ? "https://toolkit.rork.com" : toolkitURL
        guard let url = URL(string: "\(baseURL)/agent/chat") else { return nil }

        var conversationDescription = "Here is a voice conversation between two people. Each message is a voice recording. Summarize the conversation so far in warm, natural prose — not bullet points. Max 150 words. Write as if catching someone up on what's been discussed. Cover what's been talked about, where things stand, and any open questions.\n\nConversation timeline:\n"

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full

        for msg in messages {
            let timeAgo = formatter.localizedString(for: msg.date, relativeTo: Date())
            let mins = Int(msg.duration / 60)
            let secs = Int(msg.duration.truncatingRemainder(dividingBy: 60))
            let durationStr = mins > 0 ? "\(mins)m \(secs)s" : "\(secs)s"
            conversationDescription += "- \(msg.sender) sent a \(durationStr) voice message \(timeAgo)\n"
        }

        let requestMessages: [[String: String]] = [
            ["role": "user", "content": conversationDescription]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["messages": requestMessages]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                return nil
            }

            let text = String(data: data, encoding: .utf8)
            return text
        } catch {
            return nil
        }
    }

    func generateSummarySimple(messageDescriptions: String) async -> String? {
        let baseURL = toolkitURL.isEmpty ? "https://toolkit.rork.com" : toolkitURL
        guard let url = URL(string: "\(baseURL)/agent/chat") else { return nil }

        let prompt = """
        Summarize this voice conversation in warm, natural prose. Max 150 words. Not bullet points. Write as if catching a friend up on what's been discussed so far. Cover what's been talked about, where things stand, and any open questions.

        \(messageDescriptions)
        """

        let requestMessages: [[String: String]] = [
            ["role": "user", "content": prompt]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["messages": requestMessages]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, _) = try await URLSession.shared.data(for: request)
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
}
