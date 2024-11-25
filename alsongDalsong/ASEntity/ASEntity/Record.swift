import Foundation

public struct Record: Codable, Equatable {
    public var player: Player?
    public var recordOrder: UInt8?
    public var fileUrl: URL?
    
    public init() {}
}
