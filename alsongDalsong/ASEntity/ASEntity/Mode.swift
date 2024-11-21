import Foundation

public enum Mode: String, Codable {
    case humming
    case harmony
    case sync
    case instant
    case tts
    
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
}
