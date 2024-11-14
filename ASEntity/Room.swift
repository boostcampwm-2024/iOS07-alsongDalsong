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
    
    public init() {}
}
