import Foundation
import Combine
import ASRepository
import ASAudioKit
import ASEntity

final class HummingResultViewModel {
    private let player = ASAudioPlayer()
    
    @Published var currentResult: testAnswer?
    @Published var resultRecords: [ASEntity.Record] = []
    @Published var answer: testAnswer?
    
    func fetchResult() {
        currentResult = testAnswer(player: .init(id: "2134"),
                                   music: .init(title: "허각", artist: "Hello"),
                                   playlist: .init())
        resultRecords = [
            ASEntity.Record(),
            ASEntity.Record(),
            ASEntity.Record()
        ]
        
        answer = testAnswer(player: .init(id: "2134"),
                             music: .init(title: "허각", artist: "Hello"),
                             playlist: .init())
    }
}

struct testAnswer {
    let player: Player
    let music: Music
    let playlist: Playlist
    
    init(player: Player, music: Music, playlist: Playlist) {
        self.player = player
        self.music = music
        self.playlist = playlist
    }
}
