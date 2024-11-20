import ASEntity
import Combine
import Foundation

public protocol MainRepositoryProtocol {
    var number: PassthroughSubject<String?, Never> { get }
    var host: PassthroughSubject<Player?, Never> { get }
    var players: PassthroughSubject<[Player]?, Never> { get }
    var mode: PassthroughSubject<Mode?, Never> { get }
    var round: PassthroughSubject<UInt8?, Never> { get }
    var status: PassthroughSubject<Status?, Never> { get }
    var records: PassthroughSubject<[ASEntity.Record]?, Never> { get }
    var answers: PassthroughSubject<[Answer]?, Never> { get }
    var dueTime: PassthroughSubject<Date?, Never> { get }
    var selectedRecords: PassthroughSubject<[UInt8]?, Never> { get }
    var submits: PassthroughSubject<[Answer]?, Never> { get }

    func connectRoom(roomNumber: String)
}
