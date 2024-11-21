import ASAudioKit
@preconcurrency import AVFoundation

@MainActor
final class ASAudioKitDemoViewModel: Sendable, ObservableObject {
    let audioRecorder: ASAudioRecorder
    let audioPlayer: ASAudioPlayer

    @Published var recordedFile: Data?
    @Published var isRecording: Bool
    @Published var isPlaying: Bool
    @Published var playedTime: TimeInterval
    @Published var recorderAmplitude: Float = 0.0
    @Published var playerAmplitude: Float = 0.0

    private var progressTimer: Timer?
    private var recordProgressTimer: Timer?

    init(recordedFile: Data? = nil,
         isRecording: Bool = false,
         isPlaying: Bool = false,
         playedTime: TimeInterval = 0)
    {
        self.recordedFile = recordedFile
        self.isRecording = isRecording
        self.isPlaying = isPlaying
        self.playedTime = playedTime
        audioRecorder = ASAudioRecorder()
        audioPlayer = ASAudioPlayer()
    }
}

// MARK: 녹음 관련

extension ASAudioKitDemoViewModel {
    func recordButtonTapped() {
        recordedFile = nil
        if isPlaying {
            stopPlaying()
            startRecording()
        }
        else if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("데모 녹음 \(Date().timeIntervalSince1970)")

        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if !granted { return }
        }
        Task {
            await audioRecorder.startRecording(url: fileURL)
            isRecording = true
        }
        recordProgressTimer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true, block: { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                await self.updateRecorderAmplitude()
            }
        })
    }

    private func updateRecorderAmplitude() async {
        await audioRecorder.updateMeters()
        guard let averagePower = await audioRecorder.getAveragePower() else { return }
        let newAmplitude = 1.1 * pow(10.0, averagePower / 20.0)
        recorderAmplitude = min(max(newAmplitude, 0), 1)
    }

    private func stopRecording() {
        Task {
            recordedFile = await audioRecorder.stopRecording()
        }
        isRecording = false
        recordProgressTimer?.invalidate()
    }
}

// MARK: 재생 관련

extension ASAudioKitDemoViewModel {
    func startPlaying(recoredFile _: Data?, playType: PlayType) {
        guard let recordedFile else { return }

        Task {
            await audioPlayer.setOnPlaybackFinished { [weak self] in
                guard let self else { return }
                await self.stopPlaying()
            }
            await audioPlayer.startPlaying(data: recordedFile, option: playType)
            isPlaying = true
        }

        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true, block: { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                await self.updateRecorderAmplitude()
            }
        })
    }

    func stopPlaying() {
        isPlaying = false
        progressTimer?.invalidate()
    }

    func updateCurrentTime() {
        Task {
            playedTime = await audioPlayer.getCurrentTime()
        }
    }

    func getDuration(recordedFile: Data?) -> TimeInterval? {
        guard let recordedFile else { return nil }
        var timeInterval: TimeInterval?
        Task {
            timeInterval = await audioPlayer.getDuration(data: recordedFile)
        }
        return timeInterval
    }
}
