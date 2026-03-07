import SwiftUI
import SwiftData

@main
struct DinnerPartyApp: App {
    let sharedModelContainer: ModelContainer

    init() {
        let schema = Schema([
            Conversation.self,
            VoiceMessage.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // Fall back to in-memory storage so the app still launches
            print("Failed to create persistent ModelContainer: \(error). Falling back to in-memory storage.")
            let fallbackConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            sharedModelContainer = try! ModelContainer(for: schema, configurations: [fallbackConfig])
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
