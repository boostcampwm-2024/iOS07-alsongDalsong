import ASEntity
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
    public func search(for text: String, _ maxCount: Int = 25, _ offset: Int = 1) async throws -> [Music] {
        let status = await MusicAuthorization.request()
        switch status {
            case .authorized:
                do {
                    var request = MusicCatalogSearchRequest(term: text, types: [Song.self])
                    request.limit = maxCount
                    request.offset = offset

                    let result = try await request.response()
                    let music = result.songs.map { song in
                        ASEntity.Music(
                            id: song.id.rawValue,
                            title: song.title,
                            artist: song.artistName,
                            artworkUrl: song.artwork?.url(width: 300, height: 300),
                            previewUrl: song.previewAssets?.first?.url,
                            artworkBackgroundColor: song.artwork?.backgroundColor?.toHex()
                        )
                    }
                    return music
                } catch {
                    throw ASMusicError.searchError
                }
            default:
                throw ASMusicError.notAuthorized
        }
    }
}

public enum ASMusicError: Error, LocalizedError {
    case notAuthorized
    case searchError

    public var errorDescription: String? {
        switch self {
            case .notAuthorized:
                "애플 뮤직에 접근하는 권한이 없습니다."
            case .searchError:
                "노래 검색 중 오류가 발생했습니다."
        }
    }
}
