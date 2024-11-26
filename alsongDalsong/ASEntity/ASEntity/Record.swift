import Foundation

public struct Record: Codable, Equatable {
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
        if let filePath = Bundle.main.path(forResource: "SampleRecord", ofType: "m4a") {
            let fileURL = URL(fileURLWithPath: filePath)
            return fileURL
        }
        return nil
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
