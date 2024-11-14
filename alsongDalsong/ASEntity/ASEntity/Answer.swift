import Foundation

public struct Answer: Codable {
    public var player: Player?
    public var music: Music?
    public var playlist: Playlist?
    
    public init() {}
}
