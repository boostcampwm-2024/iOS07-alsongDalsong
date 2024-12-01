import ASEntity
import Combine
import Foundation

public protocol MainRepositoryProtocol {
    var myId: String? { get }
    var number: CurrentValueSubject<String?, Never> { get }
    var host: CurrentValueSubject<Player?, Never> { get }
    var players: CurrentValueSubject<[Player]?, Never> { get }
    var mode: CurrentValueSubject<Mode?, Never> { get }
    var round: CurrentValueSubject<UInt8?, Never> { get }
    var status: CurrentValueSubject<Status?, Never> { get }
    var recordOrder: CurrentValueSubject<UInt8?, Never> { get }
    var records: CurrentValueSubject<[ASEntity.Record]?, Never> { get }
    var answers: CurrentValueSubject<[Answer]?, Never> { get }
    var dueTime: CurrentValueSubject<Date?, Never> { get }
    var selectedRecords: CurrentValueSubject<[UInt8]?, Never> { get }
    var submits: CurrentValueSubject<[Answer]?, Never> { get }

    func connectRoom(roomNumber: String)
    func disconnectRoom()
    
    func postRecording(_ record: Data) async throws -> Bool
    func postResetGame() async throws -> Bool
}
