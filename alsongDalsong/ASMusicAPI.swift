import MusicKit
import Foundation

struct ASMusicAPI {
    
    ///  search 결과를 Assong으로 변환 하여 배열로 리턴하는 함수
    ///  노래 검색화면에 기본으로 뜨는 row 개수가 6개이므로 별다른 지정 없으면 기본값 6으로 지정
    func search(for text: String, _ maxCount: Int = 6) async -> [ASSong] {
        
            let status = await MusicAuthorization.request()
            
            switch status {
            case .authorized:
                do {
                    var request = MusicCatalogSearchRequest(term: text, types: [Song.self])
                    request.limit = maxCount
                    request.offset = 1
                    
                    let result = try await request.response()
                    let asSongs = result.songs.map { song in
                        let artworkURL = song.artwork?.url(width: 300, height: 300)
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

struct ASSong: Equatable {
    let title: String
    let artistName: String
    let artwork: URL?
}

