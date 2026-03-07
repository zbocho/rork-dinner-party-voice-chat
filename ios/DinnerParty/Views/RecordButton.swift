import SwiftUI

struct RecordButton: View {
    let isRecording: Bool
    let action: () -> Void

    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        Button(action: action) {
            ZStack {
                if isRecording {
                    Circle()
                        .fill(Theme.wine.opacity(0.2))
                        .frame(width: 88, height: 88)
                        .scaleEffect(pulseScale)
                }

                Circle()
                    .fill(Theme.wine)
                    .frame(width: 64, height: 64)
                    .shadow(color: Theme.wine.opacity(0.3), radius: isRecording ? 12 : 4, y: 2)

                Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                    .contentTransition(.symbolEffect(.replace))
            }
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: isRecording)
        .onChange(of: isRecording) { _, newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    pulseScale = 1.3
                }
            } else {
                withAnimation(.spring()) {
                    pulseScale = 1.0
                }
            }
        }
    }
}
