import Foundation
import AVFoundation
import ASAudioKit

class ASAudioKitDemoViewModel: ObservableObject {
    let audioRecorder: ASAudioRecorder
    let audioPlayer: ASAudioPlayer
    
    @Published var recordedFile: Data?
    @Published var isRecording: Bool
    @Published var isPlaying: Bool
    @Published var playedTime: TimeInterval
    private var progressTimer: Timer?
    
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
    }
    
    private func stopRecording() {
        recordedFile = audioRecorder.stopRecording()
        self.isRecording = false
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
        self.progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
            self.updateCurrentTime()
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
