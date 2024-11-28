import UIKit

enum AudioButtonState {
    case playing, recording, idle

    var symbol: UIImage {
        switch self {
            case .playing: UIImage(systemName: "stop.fill") ?? UIImage()
            case .recording: UIImage(systemName: "circle.fill") ?? UIImage()
            case .idle: UIImage(systemName: "play.fill") ?? UIImage()
        }
    }

    var color: UIColor {
        switch self {
            case .recording: .systemRed
            default: .white
        }
    }
}
