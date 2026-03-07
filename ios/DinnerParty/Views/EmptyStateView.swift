import SwiftUI

struct EmptyStateView: View {
    let onRecord: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "waveform")
                    .font(.system(size: 44))
                    .foregroundStyle(Theme.wine.opacity(0.4))

                Text("Dinner Party")
                    .font(.largeTitle.weight(.bold))

                Text("Start your first voice conversation.\nNo typing — just talk.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            RecordButton(isRecording: false, action: onRecord)

            Spacer()
        }
        .padding(.horizontal, 32)
    }
}
