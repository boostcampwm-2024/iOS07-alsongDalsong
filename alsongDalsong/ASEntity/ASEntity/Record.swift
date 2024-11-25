import Foundation

public struct Record: Codable, Equatable {
    public var player: Player?
    public var recordOrder: UInt8?
    public var file: Data?
    
    public init(player: Player? = nil, recordOrder: UInt8? = nil, file: Data? = nil) {
        self.player = player
        self.recordOrder = recordOrder
        self.file = file
    }
}

extension Record {
    private static let stubm4aData: Data? = {
        if let filePath = Bundle.main.path(forResource: "SampleRecord", ofType: "m4a") {
            let fileURL = URL(fileURLWithPath: filePath)
            return try? Data(contentsOf: fileURL)
        }
        return nil
    }()
    // 1이 허밍 시작임.
    public static let recordStub1_1 = Record(player: Player.playerStub1, recordOrder: 1, file: stubm4aData)
    public static let recordStub1_2 = Record(player: Player.playerStub1, recordOrder: 2, file: stubm4aData)
    public static let recordStub1_3 = Record(player: Player.playerStub1, recordOrder: 3, file: stubm4aData)
    public static let recordStub2_1 = Record(player: Player.playerStub2, recordOrder: 1, file: stubm4aData)
    public static let recordStub2_2 = Record(player: Player.playerStub2, recordOrder: 2, file: stubm4aData)
    public static let recordStub2_3 = Record(player: Player.playerStub2, recordOrder: 3, file: stubm4aData)
    public static let recordStub3_1 = Record(player: Player.playerStub3, recordOrder: 1, file: stubm4aData)
    public static let recordStub3_2 = Record(player: Player.playerStub3, recordOrder: 2, file: stubm4aData)
    public static let recordStub3_3 = Record(player: Player.playerStub3, recordOrder: 3, file: stubm4aData)
    public static let recordStub4_1 = Record(player: Player.playerStub4, recordOrder: 1, file: stubm4aData)
    public static let recordStub4_2 = Record(player: Player.playerStub4, recordOrder: 2, file: stubm4aData)
    public static let recordStub4_3 = Record(player: Player.playerStub4, recordOrder: 3, file: stubm4aData)
}
