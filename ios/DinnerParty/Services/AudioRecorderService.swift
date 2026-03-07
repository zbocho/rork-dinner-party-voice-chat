import AVFoundation
import Foundation

@Observable
final class AudioRecorderService: NSObject {
    var isRecording: Bool = false
    var recordingDuration: TimeInterval = 0
    var isPastFiveMinutes: Bool = false

    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    private var currentFileURL: URL?

    func startRecording() async -> Bool {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
        } catch {
            return false
        }

        let granted = await AVAudioApplication.requestRecordPermission()
        guard granted else { return false }

        let fileName = "voice_\(UUID().uuidString).m4a"
        guard let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return false
        }
        let fileURL = docs.appendingPathComponent(fileName)
        currentFileURL = fileURL

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            isRecording = true
            recordingDuration = 0
            isPastFiveMinutes = false
            startTimer()
            return true
        } catch {
            return false
        }
    }

    func stopRecording() -> (url: URL, duration: TimeInterval, fileName: String)? {
        guard let recorder = audioRecorder, recorder.isRecording else { return nil }
        let duration = recorder.currentTime
        recorder.stop()
        stopTimer()
        isRecording = false

        guard let fileURL = currentFileURL else { return nil }
        let fileName = fileURL.lastPathComponent
        return (url: fileURL, duration: duration, fileName: fileName)
    }

    func cancelRecording() {
        audioRecorder?.stop()
        audioRecorder?.deleteRecording()
        stopTimer()
        isRecording = false
        recordingDuration = 0
        isPastFiveMinutes = false
        currentFileURL = nil
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.recordingDuration = self.audioRecorder?.currentTime ?? 0
                if self.recordingDuration >= 300 && !self.isPastFiveMinutes {
                    self.isPastFiveMinutes = true
                }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

extension AudioRecorderService: AVAudioRecorderDelegate {
    nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        Task { @MainActor in
            self.isRecording = false
        }
    }
}
