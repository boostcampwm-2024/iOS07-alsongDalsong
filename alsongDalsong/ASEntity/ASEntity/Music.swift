import Foundation

public struct Music: Codable, Equatable, Identifiable, Sendable, Hashable {
    public let id: String?
    public let title: String?
    public let artist: String?
    public let artworkUrl: URL?
    public let previewUrl: URL?
    public let lyrics: String?
    public let artworkBackgroundColor: String?

    public init() {}

    public init(title: String, artist: String) {
        self.title = title
        self.artist = artist
    }
  
    public init(id: String, title: String?, artist: String?, artworkUrl: URL?, previewUrl: URL?, artworkBackgroundColor: String?) {
        self.id = id
        self.title = title
        self.artist = artist
        self.artworkUrl = artworkUrl
        self.previewUrl = previewUrl
        self.artworkBackgroundColor = artworkBackgroundColor
    }
}

extension Music {
    public init(_ record: ASEntity.Record) {
        self.previewUrl = record.fileUrl
    }
}

extension Music {
    public static let musicStub1 = Music(title: "네 번호가 뜨는 일", artist: "이예준")
    public static let musicStub2 = Music(title: "그거 아세요?", artist: "이혁")
    public static let musicStub3 = Music(title: "으아~", artist: "김흥국")
    public static let musicStub4 = Music(title: "이브, 프시케 그리고 푸른 수염의 아내", artist: "르세라핌")
}
