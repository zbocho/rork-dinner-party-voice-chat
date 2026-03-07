import SwiftUI

struct MessagesView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "message.fill")
                .font(.largeTitle)
                .foregroundStyle(.blue)
            Text("DinnerPartyMessages")
                .font(.headline)
            Text("Your iMessage app is ready!")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
