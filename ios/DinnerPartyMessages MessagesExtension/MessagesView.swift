import SwiftUI
import SwiftData

struct MessagesView: View {
    var onRequestExpand: (() -> Void)?
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ConversationViewModel()

    var body: some View {
        ConversationView()
    }
}
