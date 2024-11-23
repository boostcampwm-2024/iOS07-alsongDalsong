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

extension Music {
    public static let musicStub1 = Music(title: "네 번호가 뜨는 일", artist: "이예준")
    public static let musicStub2 = Music(title: "그거 아세요?", artist: "이혁")
    public static let musicStub3 = Music(title: "으아~", artist: "김흥국")
    public static let musicStub4 = Music(title: "이브, 프시케 그리고 푸른 수염의 아내", artist: "르세라핌")
}
