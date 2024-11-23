import Foundation

public struct Record: Codable, Equatable {
    public var player: Player?
    public var round: Int?
    public var file: Data?
    
    public init(player: Player? = nil, round: Int? = nil, file: Data? = nil) {
        self.player = player
        self.round = round
        self.file = file
    }
}

extension Record {
    public static let recordStub1_1 = Record(player: Player.playerStub1, round: 1, file: nil)
    public static let recordStub1_2 = Record(player: Player.playerStub1, round: 2, file: nil)
    public static let recordStub1_3 = Record(player: Player.playerStub1, round: 3, file: nil)
    public static let recordStub2_1 = Record(player: Player.playerStub2, round: 1, file: nil)
    public static let recordStub2_2 = Record(player: Player.playerStub2, round: 2, file: nil)
    public static let recordStub2_3 = Record(player: Player.playerStub2, round: 3, file: nil)
    public static let recordStub3_1 = Record(player: Player.playerStub3, round: 1, file: nil)
    public static let recordStub3_2 = Record(player: Player.playerStub3, round: 2, file: nil)
    public static let recordStub3_3 = Record(player: Player.playerStub3, round: 3, file: nil)
    public static let recordStub4_1 = Record(player: Player.playerStub4, round: 1, file: nil)
    public static let recordStub4_2 = Record(player: Player.playerStub4, round: 2, file: nil)
    public static let recordStub4_3 = Record(player: Player.playerStub4, round: 3, file: nil)
}
