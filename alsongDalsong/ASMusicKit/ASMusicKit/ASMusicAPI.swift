import Foundation
import MusicKit

public struct ASMusicAPI {
    public init() {}
    /// MusicKit을 통해 AppleMusic
    /// - Parameters:
    ///   - text: 검색 요청을 보낼 검색어
    ///   - maxCount: 검색해서 찾아올 음악의 갯수 기본값 설정은 25
    /// - Returns: ASSong의 배열
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
                        let artworkURL = song.artwork?.url(width: 100, height: 100)
                        return ASSong(title: song.title, artistName: song.artistName, artwork: artworkURL)
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

public struct ASSong: Equatable, Sendable {
    public let title: String
    public let artistName: String
    public let artwork: URL?
}
