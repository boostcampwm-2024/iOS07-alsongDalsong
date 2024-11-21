import Foundation

public struct Music: Codable, Equatable {
    public var id: UUID?
    public var title: String?
    public var artist: String?
    public var lyrics: String?

    public init() {}
    
    public init(title: String, artist: String) {
        self.title = title
        self.artist = artist
    }
}
