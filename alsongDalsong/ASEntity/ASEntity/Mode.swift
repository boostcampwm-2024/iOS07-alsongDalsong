import Foundation

public enum Mode: String, Codable, CaseIterable, Identifiable {
    case humming
    case harmony
    case sync
    case instant
    case tts
    
    public var id : String { self.rawValue }
    
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
        case .sync: return "싱크"
        case .instant: return "인스턴트"
        case .tts: return "TTS"
        }
    }
    
    public var description: String {
        switch self {
        case .humming: return "허밍 모드 설명"
        case .harmony: return "하모니 모드 설명"
        case .sync: return "싱크 모드 설명"
        case .instant: return "인스턴트 모드 설명"
        case .tts: return "TTS 모드 설명"
        }
    }
    
    public var imageName: String {
        switch self {
        case .humming: return "fake"
        case .harmony: return "fake"
        case .sync: return "fake"
        case .instant: return "fake"
        case .tts: return "fake"
        }
    }
}
