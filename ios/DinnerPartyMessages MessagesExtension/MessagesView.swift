import SwiftUI
import SwiftData

struct MessagesView: View {
    var onRequestExpand: (() -> Void)?

    var body: some View {
        ConversationView()
    }
}
