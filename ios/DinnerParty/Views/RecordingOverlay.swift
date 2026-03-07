import SwiftUI

struct RecordingOverlay: View {
    let duration: TimeInterval
    let isPastFiveMinutes: Bool
    let hasPendingRecording: Bool
    let pendingDuration: TimeInterval
    let onStop: () -> Void
    let onCancel: () -> Void
    let onSend: () -> Void

    private var formattedDuration: String {
        let d = hasPendingRecording ? pendingDuration : duration
        let mins = Int(d) / 60
        let secs = Int(d) % 60
        return String(format: "%d:%02d", mins, secs)
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                if !hasPendingRecording {
                    Text("Recording")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                } else {
                    Text("Ready to send")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                }

                Text(formattedDuration)
                    .font(.system(size: 48, weight: .light, design: .default))
                    .foregroundStyle(.white)
                    .monospacedDigit()

                if isPastFiveMinutes && !hasPendingRecording {
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text("Over 5 minutes")
                            .font(.caption.weight(.medium))
                    }
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.white.opacity(0.1))
                    .clipShape(Capsule())
                }
            }

            if hasPendingRecording {
                HStack(spacing: 40) {
                    Button(action: onCancel) {
                        VStack(spacing: 8) {
                            Image(systemName: "xmark")
                                .font(.title3.weight(.semibold))
                                .frame(width: 52, height: 52)
                                .background(.white.opacity(0.15))
                                .clipShape(Circle())

                            Text("Discard")
                                .font(.caption.weight(.medium))
                        }
                        .foregroundStyle(.white.opacity(0.8))
                    }

                    Button(action: onSend) {
                        VStack(spacing: 8) {
                            Image(systemName: "arrow.up")
                                .font(.title3.weight(.bold))
                                .frame(width: 52, height: 52)
                                .background(Theme.wine)
                                .clipShape(Circle())

                            Text("Send")
                                .font(.caption.weight(.medium))
                        }
                        .foregroundStyle(.white)
                    }
                }
            } else {
                RecordButton(isRecording: true, action: onStop)
            }

            Spacer()
                .frame(height: 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.92))
    }
}
