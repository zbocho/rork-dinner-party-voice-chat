import SwiftUI

struct SummaryCardView: View {
    let summary: String
    let isGenerating: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.wine)

                Text("AI:DR")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Theme.wine)
                    .tracking(0.5)

                Spacer()

                if isGenerating {
                    ProgressView()
                        .controlSize(.small)
                        .tint(Theme.wine)
                }
            }

            if summary.isEmpty && !isGenerating {
                Text("Your conversation summary will appear here after the first voice message.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .italic()
            } else if !summary.isEmpty {
                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(Theme.wineFaded)
        .clipShape(.rect(cornerRadius: 16))
    }
}
