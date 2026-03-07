import SwiftUI

struct VoiceMessageRow: View {
    let message: VoiceMessage
    let isCurrentlyPlaying: Bool
    let isPlaying: Bool
    let playbackProgress: Double
    let currentTime: TimeInterval
    let onTap: () -> Void

    private var formattedDuration: String {
        message.duration.formattedMinsSecs
    }

    private var formattedCurrentTime: String {
        currentTime.formattedMinsSecs
    }

    private var timeLabel: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: message.createdAt)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(message.isMine ? Theme.wine : Color(.tertiarySystemFill))
                    .frame(width: 36, height: 36)

                Text(message.senderInitial)
                    .font(.system(.caption, weight: .bold))
                    .foregroundStyle(message.isMine ? .white : .primary)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(message.senderName)
                        .font(.subheadline.weight(.semibold))

                    Spacer()

                    Text(timeLabel)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

                Button(action: onTap) {
                    HStack(spacing: 12) {
                        Image(systemName: isCurrentlyPlaying && isPlaying ? "pause.fill" : "play.fill")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Theme.wine)
                            .frame(width: 32, height: 32)
                            .background(Theme.wineFaded)
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 4) {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color(.quaternarySystemFill))
                                        .frame(height: 4)

                                    if isCurrentlyPlaying {
                                        Capsule()
                                            .fill(Theme.wine)
                                            .frame(width: geo.size.width * playbackProgress, height: 4)
                                    }
                                }
                            }
                            .frame(height: 4)

                            Text(isCurrentlyPlaying ? formattedCurrentTime : formattedDuration)
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
    }
}
