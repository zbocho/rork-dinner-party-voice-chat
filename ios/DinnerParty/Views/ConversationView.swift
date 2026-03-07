import SwiftUI
import SwiftData

struct ConversationView: View {
    @State private var viewModel = ConversationViewModel()
    @Environment(\.modelContext) private var modelContext
    @State private var showRecordingOverlay: Bool = false
    @State private var showRecordingUnavailableAlert: Bool = false

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            if viewModel.messages.isEmpty {
                EmptyStateView {
                    Task { await startRecording() }
                }
            } else {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 16) {
                            SummaryCardView(
                                summary: viewModel.conversation?.summary ?? "",
                                isGenerating: viewModel.isGeneratingSummary
                            )

                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.messages, id: \.id) { message in
                                    VoiceMessageRow(
                                        message: message,
                                        isCurrentlyPlaying: viewModel.player.currentMessageID == message.id,
                                        isPlaying: viewModel.player.isPlaying && viewModel.player.currentMessageID == message.id,
                                        playbackProgress: viewModel.player.currentMessageID == message.id ? viewModel.player.progress : 0,
                                        currentTime: viewModel.player.currentMessageID == message.id ? viewModel.player.currentTime : 0,
                                        onTap: { viewModel.playMessage(message) }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 100)
                    }

                    Spacer(minLength: 0)
                }
                .safeAreaInset(edge: .bottom) {
                    VStack(spacing: 0) {
                        Divider()

                        RecordButton(isRecording: false) {
                            Task { await startRecording() }
                        }
                        .padding(.vertical, 12)
                    }
                    .background(.ultraThinMaterial)
                }
            }

            if showRecordingOverlay {
                RecordingOverlay(
                    duration: viewModel.recordingDuration,
                    isPastFiveMinutes: viewModel.isPastFiveMinutes,
                    hasPendingRecording: viewModel.hasPendingRecording,
                    pendingDuration: viewModel.pendingRecordingDuration,
                    onStop: {
                        viewModel.stopRecording()
                        if !viewModel.hasPendingRecording {
                            showRecordingOverlay = false
                        }
                    },
                    onCancel: {
                        viewModel.cancelRecording()
                        showRecordingOverlay = false
                    },
                    onSend: {
                        viewModel.sendRecording()
                        showRecordingOverlay = false
                    }
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showRecordingOverlay)
        .alert("Microphone Unavailable", isPresented: $showRecordingUnavailableAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Install this app on your device via the Rork App to record audio.")
        }
        .onAppear {
            viewModel.setup(modelContext: modelContext)
        }
    }

    private func startRecording() async {
        let started = await viewModel.startRecording()
        if started {
            showRecordingOverlay = true
        } else {
            showRecordingUnavailableAlert = true
        }
    }
}
