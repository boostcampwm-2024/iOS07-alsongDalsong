import Foundation

public struct Record: Codable, Equatable {
    public var player: Player?
    public var recordOrder: UInt8?
    public var fileUrl: URL?
    
    public init() {}
}

public extension ASEntity.Record {
    func mapToMusic() -> Music {
        Music(title: nil, artist: nil, artworkUrl: nil, previewUrl: fileUrl)
    }
}
