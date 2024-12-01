import Foundation

public struct Room: Codable {
    public var number: String?
    public var host: Player?
    public var players: [Player]?
    public var mode: Mode?
    public var round: UInt8?
    public var status: Status?
    public var recordOrder: UInt8?
    public var records: [Record]?
    public var answers: [Answer]?
    public var dueTime: Date?
    public var selectedRecords: [UInt8]?
    public var submits: [Answer]?
    
    public init(
        number: String? = nil,
        host: Player? = nil,
        players: [Player]? = nil,
        mode: Mode? = nil,
        round: UInt8? = nil,
        status: Status? = nil,
        recordOrder: UInt8? = nil,
        records: [Record]? = nil,
        answers: [Answer]? = nil,
        dueTime: Date? = nil,
        selectedRecords: [UInt8]? = nil,
        submits: [Answer]? = nil
    ) {
        self.number = number
        self.host = host
        self.players = players
        self.mode = mode
        self.round = round
        self.status = status
        self.recordOrder = recordOrder
        self.records = records
        self.answers = answers
        self.dueTime = dueTime
        self.selectedRecords = selectedRecords
        self.submits = submits
    }
}

extension Room: CustomStringConvertible {
    public var description: String {
        return """
        number: \(number ?? "nil")
        host: \(host?.description ?? "nil")
        players: \(players?.description ?? "nil")
        mode: \(mode?.title ?? "nil")
        round: \(round ?? 0)
        status: \(status?.description ?? "nil")
        recordOrder: \(recordOrder ?? 0)
        records: \(records?.description ?? "nil")
        answers: \(answers?.description ?? "nil")
        dueTime: \(dueTime?.description ?? "nil")
        selectedRecords: \(selectedRecords?.description ?? "nil")
        submits: \(submits?.description ?? "nil")
        """
    }
}
