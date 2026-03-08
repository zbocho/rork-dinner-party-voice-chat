import AVFoundation
import Foundation

@Observable
final class AudioPlayerService: NSObject {
    var isPlaying: Bool = false
    var currentMessageID: String?
    var currentTime: TimeInterval = 0
    var duration: TimeInterval = 0

    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?

    func play(url: URL, messageID: String) {
        stop()

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)

            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            duration = audioPlayer?.duration ?? 0
            currentTime = 0
            currentMessageID = messageID
            audioPlayer?.play()
            isPlaying = true
            startTimer()
        } catch {
            isPlaying = false
        }
    }

    func pause() {
        audioPlayer?.pause()
        isPlaying = false
        stopTimer()
    }

    func resume() {
        audioPlayer?.play()
        isPlaying = true
        startTimer()
    }

    func stop() {
        audioPlayer?.stop()
        isPlaying = false
        currentMessageID = nil
        currentTime = 0
        duration = 0
        stopTimer()
    }

    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
        currentTime = time
    }

    var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.currentTime = self.audioPlayer?.currentTime ?? 0
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

extension AudioPlayerService: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.isPlaying = false
            self.currentMessageID = nil
            self.currentTime = 0
            self.stopTimer()
        }
    }
}
