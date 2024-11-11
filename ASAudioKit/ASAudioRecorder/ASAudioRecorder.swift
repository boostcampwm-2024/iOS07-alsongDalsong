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
    
    func stopRecording() {}
}
