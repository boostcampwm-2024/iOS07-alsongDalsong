import AVFoundation

public enum PlayType {
    case full
    case partial(time: Int)
}

public final class ASAudioPlayer: NSObject, AVAudioPlayerDelegate {
    private var audioPlayer: AVAudioPlayer?

    public override init() {}
    
    public var onPlaybackFinished: (() -> Void)?
    ///녹음파일을 재생하고 옵션에 따라 재생시간을 설정합니다.
    public func startPlaying(data: Data, option: PlayType) {
        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
        } catch {
            // TODO: 오디오 객체생성 실패 시 처리
        }

        switch option {
        case .full:
            audioPlayer?.play()
        case .partial(let time):
            audioPlayer?.currentTime = 0
            audioPlayer?.play()
            let timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(time), repeats: false) { [weak self] _ in
                self?.audioPlayer?.stop()
            }
        }
    }
    ///AVPlayer객체의 재생여부를 확인합니다.
    public func isPlaying() -> Bool {
        if let audioPlayer {
            return audioPlayer.isPlaying
        }
        return false
    }
    ///현재 플레이되고 있는 파일의 진행시간을 리턴합니다.
    public func getCurrentTime() -> TimeInterval {
        return audioPlayer?.currentTime ?? 0
    }
    ///녹음파일의 총 녹음시간을 리턴합니다.
    public func getDuration(data: Data) -> TimeInterval {
        if audioPlayer == nil {
            do {
                audioPlayer = try AVAudioPlayer(data: data)
            } catch {
                // TODO: 오디오 객체생성 실패 시 처리
            }
        }
        return audioPlayer?.duration ?? 0
    }
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onPlaybackFinished?()
    }
}
