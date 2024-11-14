import Foundation

public struct Record: Codable {
    public var player: Player?
    public var round: Int?
    public var file: Data?
    
    public init() {}
}
