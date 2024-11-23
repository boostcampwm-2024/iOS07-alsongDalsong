import Foundation

public struct Answer: Codable, Equatable {
    public var player: Player?
    public var music: Music?
    public var playlist: Playlist?
    
    public init(player: Player?, music: Music?, playlist: Playlist?) {
        self.player = player
        self.music = music
        self.playlist = playlist
    }
}

extension Answer {
    public static let answerStub1 = Answer(player: Player(id: ""),
                                    music: Music(),
                                    playlist: Playlist())
}
