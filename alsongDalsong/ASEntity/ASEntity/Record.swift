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
    private static let stubm4aData: Data? = {
        if let filePath = Bundle.main.path(forResource: "SampleRecord", ofType: "m4a") {
            let fileURL = URL(fileURLWithPath: filePath)
            print("파일은 찾음")
            return try? Data(contentsOf: fileURL)
        }
        print("파일도 못찾음")
        return nil
    }()
    public static let recordStub1_1 = Record(player: Player.playerStub1, round: 1, file: stubm4aData)
    public static let recordStub1_2 = Record(player: Player.playerStub1, round: 2, file: stubm4aData)
    public static let recordStub1_3 = Record(player: Player.playerStub1, round: 3, file: stubm4aData)
    public static let recordStub2_1 = Record(player: Player.playerStub2, round: 1, file: stubm4aData)
    public static let recordStub2_2 = Record(player: Player.playerStub2, round: 2, file: stubm4aData)
    public static let recordStub2_3 = Record(player: Player.playerStub2, round: 3, file: stubm4aData)
    public static let recordStub3_1 = Record(player: Player.playerStub3, round: 1, file: stubm4aData)
    public static let recordStub3_2 = Record(player: Player.playerStub3, round: 2, file: stubm4aData)
    public static let recordStub3_3 = Record(player: Player.playerStub3, round: 3, file: stubm4aData)
    public static let recordStub4_1 = Record(player: Player.playerStub4, round: 1, file: stubm4aData)
    public static let recordStub4_2 = Record(player: Player.playerStub4, round: 2, file: stubm4aData)
    public static let recordStub4_3 = Record(player: Player.playerStub4, round: 3, file: stubm4aData)
}
