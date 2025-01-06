import Foundation

public struct Record: Codable, Equatable, Sendable, Hashable {
    public var player: Player?
    public var recordOrder: UInt8?
    public var fileUrl: URL?
    
    public init(player: Player? = nil, recordOrder: UInt8? = nil, fileUrl: URL? = nil) {
        self.player = player
        self.recordOrder = recordOrder
        self.fileUrl = fileUrl
    }
}

extension Record {
    private static let stubm4aData: URL? = {
        return URL(string: "https://firebasestorage.googleapis.com/v0/b/alsongdalsong-boostcamp.firebasestorage.app/o/audios%2Ffeef1adc-d0aa-4af7-b2c6-16f2dda339e9_mzaf_16018936309126267135.plus.aac.p.m4a?alt=media&token=60d59d23-a9f8-4ac6-ae85-5f6824f6e39a")
    }()
  
    public static let recordStub1_1 = Record(player: Player.playerStub1, recordOrder: 0, fileUrl: stubm4aData)
    public static let recordStub1_2 = Record(player: Player.playerStub1, recordOrder: 1, fileUrl: stubm4aData)
    public static let recordStub1_3 = Record(player: Player.playerStub1, recordOrder: 2, fileUrl: stubm4aData)
    public static let recordStub2_1 = Record(player: Player.playerStub2, recordOrder: 0, fileUrl: stubm4aData)
    public static let recordStub2_2 = Record(player: Player.playerStub2, recordOrder: 1, fileUrl: stubm4aData)
    public static let recordStub2_3 = Record(player: Player.playerStub2, recordOrder: 2, fileUrl: stubm4aData)
    public static let recordStub3_1 = Record(player: Player.playerStub3, recordOrder: 0, fileUrl: stubm4aData)
    public static let recordStub3_2 = Record(player: Player.playerStub3, recordOrder: 1, fileUrl: stubm4aData)
    public static let recordStub3_3 = Record(player: Player.playerStub3, recordOrder: 2, fileUrl: stubm4aData)
    public static let recordStub4_1 = Record(player: Player.playerStub4, recordOrder: 0, fileUrl: stubm4aData)
    public static let recordStub4_2 = Record(player: Player.playerStub4, recordOrder: 1, fileUrl: stubm4aData)
    public static let recordStub4_3 = Record(player: Player.playerStub4, recordOrder: 2, fileUrl: stubm4aData)
}
