import Foundation

protocol PlayerInfo {
    var playerName: String { get set }
    var playerAvatarData: Data { get set }
}

struct MappedAnswer: Hashable, PlayerInfo {
    var artworkData: Data
    var previewData: Data
    var title: String
    var artist: String
    var playerName: String
    var playerAvatarData: Data

    init(_ artworkData: Data?, _ previewData: Data?, _ title: String?, _ artist: String?, _ playerName: String?, _ playerAvatarData: Data?) {
        self.artworkData = artworkData ?? Data()
        self.previewData = previewData ?? Data()
        self.title = title ?? ""
        self.artist = artist ?? ""
        self.playerName = playerName ?? ""
        self.playerAvatarData = playerAvatarData ?? Data()
    }
}

struct MappedRecord: Hashable, PlayerInfo {
    var recordData: Data
    var recordAmplitudes: [CGFloat]
    var playerName: String
    var playerAvatarData: Data

    init(_ recordData: Data?, _ recordAmplitudes: [CGFloat], _ playerName: String?, _ playerAvatarData: Data?) {
        self.recordData = recordData ?? Data()
        self.recordAmplitudes = recordAmplitudes
        self.playerName = playerName ?? ""
        self.playerAvatarData = playerAvatarData ?? Data()
    }
}

enum ResultPhase: Equatable {
    case none
    case answer
    case record(Int)
    case submit

    var playOption: PlayType {
        switch self {
            case .record: .full
            default: .partial(time: 10)
        }
    }

    func audioData(_ result: Result) -> Data? {
        switch self {
            case .answer: result.answer?.previewData
            case let .record(count): result.records[count].recordData
            case .submit: result.submit?.previewData
            default: nil
        }
    }
}

enum PlayType {
    case full
    case partial(time: Int)
}
