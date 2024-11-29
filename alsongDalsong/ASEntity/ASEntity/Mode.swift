import Foundation

public enum Mode: String, Codable, CaseIterable, Identifiable {
    case humming
    case harmony
    case sync
    case instant
    case tts

    public var id: String { rawValue }

    public var Index: Int {
        switch self {
            case .humming: 1
            case .harmony: 2
            case .sync: 3
            case .instant: 4
            case .tts: 5
        }
    }

    public static func fromIndex(_ index: Int) -> Mode? {
        switch index {
            case 1: return .humming
            case 2: return .harmony
            case 3: return .sync
            case 4: return .instant
            case 5: return .tts
            default: return nil
        }
    }

    public var title: String {
        switch self {
            case .humming: return "허밍"
            case .harmony: return "하모니"
            case .sync: return "이구동성"
            case .instant: return "찰나의순간"
            case .tts: return "TTS"
        }
    }

    public var description: String {
        switch self {
            case .humming: return "원하는 노래를 선택하고 허밍을 하세요! 다음 사람부터 당신의 허밍을 따라하게 됩니다. 마지막 친구는 허밍을 듣고 어떤 노래인지 맞출 수 있을까요?"
            case .harmony: return "각 플레이어는 하나의 파트를 녹음하고, 그 녹음을 합쳐 완벽한 하모니를 만들어야 합니다. 플레이어들이 녹음한 각각의 음성을 합치면서, 누구의 파트가 가장 잘 어우러지는지 확인하세요"
            case .sync: return "동시에 부르는 음악을 맞추는 모드입니다. "
            case .instant: return "1초 듣고 맞추기 모드는 짧은 시간에 최대한의 집중을 요구하는 모드입니다. 1초동안 랜덤으로 선택된 노래 클립을 듣고, 무엇인지 맞춰야 합니다. 짧은 시간에 어떤 노래인지 맞출 수 있을까요?"
            case .tts: return "음악의 가사만 듣고 노래를 맞추는 모드입니다. 선택된 노래의 가사를 TTS로 읽어주며, 플레이어는 그 가사에 해당하는 노래를 맞춰야 합니다."
        }
    }

    public var imageName: String {
        switch self {
            case .humming: return "humming"
            case .harmony: return "harmony"
            case .sync: return "sync"
            case .instant: return "instant"
            case .tts: return "tts"
        }
    }
}
