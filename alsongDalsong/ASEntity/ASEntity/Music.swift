import Foundation

public struct Music: Codable, Equatable {
    public var id: UUID?
    public var title: String?
    public var artist: String?
    public var artworkUrl: URL?
    public var previewUrl: URL?
    public var lyrics: String?

    public init() {}
    
    public init(title: String, artist: String) {
        self.title = title
        self.artist = artist
    }
    
    public init(title: String?, artist: String?, artworkUrl: URL?, previewUrl: URL?) {
        self.title = title
        self.artist = artist
        self.artworkUrl = artworkUrl
        self.previewUrl = previewUrl
    }
}

extension Music {
    public init(_ record: ASEntity.Record) {
        self.previewUrl = record.fileUrl
    }
}
