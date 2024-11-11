import AVFoundation

class ASAudioRecorder {
    private var audioRecorder: AVAudioRecorder? = nil
    
    func startRecording(url: URL) {
        let settings = [
            AVFormatIDKey : Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey : 12000,
            AVNumberOfChannelsKey : 1,
            AVEncoderAudioQualityKey : AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.record()
        } catch {
            //
        }
    }
    
    func isRecording() -> Bool {
        if let audioRecorder {
            return audioRecorder.isRecording
        }
        return false
    }
    
    func stopRecording() {
        // 녹음 종료 시에 어디 저장되었는지 리턴해줄 필요가 있을 듯, 저장된 녹음파일을 network에 던져줄 필요가 있음.
        audioRecorder?.stop()
    }
}
