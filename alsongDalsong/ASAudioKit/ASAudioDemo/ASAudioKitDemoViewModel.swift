import Foundation
@preconcurrency import AVFoundation
import ASAudioKit

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
         playedTime: TimeInterval = 0) {
        self.recordedFile = recordedFile
        self.isRecording = isRecording
        self.isPlaying = isPlaying
        self.playedTime = playedTime
        self.audioRecorder = ASAudioRecorder()
        self.audioPlayer = ASAudioPlayer()
    }
}

//MARK: 녹음 관련
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
            if !granted {return}
        }
        audioRecorder.startRecording(url: fileURL)
        self.isRecording = true
        self.recordProgressTimer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true, block: {[weak self] _ in
            Task { @MainActor in
                guard let self else {return}
                self.audioRecorder.updateMeters()
                
                guard let averagePower = self.audioRecorder.getAveragePower() else { return }
                let newAmplitude = 1.1 * pow(10.0, averagePower / 20.0)
                self.recorderAmplitude = min(max(newAmplitude, 0), 1)
            }
        })
    }
    
    private func stopRecording() {
        recordedFile = audioRecorder.stopRecording()
        self.isRecording = false
        self.recordProgressTimer?.invalidate()
    }
}

//MARK: 재생 관련
extension ASAudioKitDemoViewModel {
    func startPlaying(recoredFile: Data?, playType: PlayType) {
        guard let recordedFile else { return }
        audioPlayer.onPlaybackFinished = { [weak self] in
            self?.stopPlaying()
        }
        audioPlayer.startPlaying(data: recordedFile, option: playType)
        self.isPlaying = true
        self.progressTimer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true, block: {[weak self] _ in
            Task { @MainActor in
                guard let self else {return}
                self.updateCurrentTime()
                
                self.audioPlayer.updateMeters()
                guard let averagePower = self.audioPlayer.getAveragePower() else { return }
                let newAmplitude = 1.1 * pow(10.0, averagePower / 20.0)
                self.playerAmplitude = min(max(newAmplitude, 0), 1)
            }
        })
    }
    
    func stopPlaying() {
        self.isPlaying = false
        self.progressTimer?.invalidate()
    }
    
    func updateCurrentTime() {
        self.playedTime = audioPlayer.getCurrentTime()
    }
    
    func getDuration(recordedFile: Data?) -> TimeInterval? {
        guard let recordedFile else { return nil }
        return audioPlayer.getDuration(data: recordedFile)
    }
}
