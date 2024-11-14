import Foundation

public struct Room {
    public var number: String?
    public var host: Player?
    public var players: [Player]?
    public var mode: Mode?
    public var round: Int?
    public var status: Status?
    public var records: [[Record]]?
    public var answers: [Answer]?
    public var dueTime: Date?
    public var selectedRecords: [Int]?
    public var submits: [Answer]?
    
    public init(
        number: String? = nil,
        host: Player? = nil,
        players: [Player]? = nil,
        mode: Mode? = nil,
        round: Int? = nil,
        status: Status? = nil,
        records: [[Record]]? = nil,
        answers: [Answer]? = nil,
        dueTime: Date? = nil,
        selectedRecords: [Int]? = nil,
        submits: [Answer]? = nil
    ) {
        self.number = number
        self.host = host
        self.players = players
        self.mode = mode
        self.round = round
        self.status = status
        self.records = records
        self.answers = answers
        self.dueTime = dueTime
        self.selectedRecords = selectedRecords
        self.submits = submits
    }
}
