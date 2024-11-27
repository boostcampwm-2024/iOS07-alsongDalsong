import Foundation
import MusicKit

public struct ASMusicAPI {
    public init() {}
    /// MusicKit을 통해 AppleMusic
    /// - Parameters:
    ///   - text: 검색 요청을 보낼 검색어
    ///   - maxCount: 검색해서 찾아올 음악의 갯수 기본값 설정은 25
    /// - Returns: ASSong의 배열
    @MainActor
    public func search(for text: String, _ maxCount: Int = 25, _ offset: Int = 1) async -> [ASSong] {
        let status = await MusicAuthorization.request()
        switch status {
            case .authorized:
                do {
                    var request = MusicCatalogSearchRequest(term: text, types: [Song.self])
                    request.limit = maxCount
                    request.offset = offset
                    
                    let result = try await request.response()
                    let asSongs = result.songs.map { song in
                        return ASSong(
                            id: song.isrc,
                            title: song.title,
                            artistName: song.artistName,
                            artwork: song.artwork,
                            previewURL: song.previewAssets?.first?.url
                        )
                    }
                    return asSongs
                } catch {
                    print(String(describing: error))
                    return []
                }
            default:
                print("Not authorized to access Apple Music")
                return []
        }
    }
}

public struct ASSong: Equatable, Identifiable {
    public init(
        id: String? = nil,
        title: String = "선택된 곡 없음",
        artistName: String = "아티스트",
        artwork: Artwork? = nil,
        previewURL: URL? = nil
    ) {
        self.id = id
        self.title = title
        self.artistName = artistName
        self.artwork = artwork
        self.previewURL = previewURL
    }
    public var id: String?
    public let title: String
    public let artistName: String
    public let artwork: Artwork?
    public let previewURL: URL?
}
