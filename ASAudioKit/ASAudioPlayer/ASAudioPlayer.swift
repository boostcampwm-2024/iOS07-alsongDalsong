import AVFoundation

public enum PlayType {
    case allPlay
    case play(time: Int)
}

public class ASAudioPlayer {
    private var audioPlayer: AVAudioPlayer? = nil
    
    public init() {}
    
    public func startPlaying(data: Data, option: PlayType) {
        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.prepareToPlay()
        } catch {
            //TODO: 오디오 객체생성 실패 시 처리
        }
        
        switch option {
        case .allPlay:
            audioPlayer?.play()
        case .play(let time):
            audioPlayer?.currentTime = 0
            let timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(time), repeats: false) { [weak self] _ in
                self?.audioPlayer?.stop()
            }
        }
    }
    
    public func isPlaying() -> Bool {
        if let audioPlayer {
            return audioPlayer.isPlaying
        }
        return false
    }
    
    public func getCurrentTime() -> TimeInterval {
        return audioPlayer?.currentTime ?? 0
    }
}
