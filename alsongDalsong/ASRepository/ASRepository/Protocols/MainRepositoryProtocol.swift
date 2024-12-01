import ASEntity
import Combine
import Foundation

public protocol MainRepositoryProtocol {
    var myId: String? { get }
    var room: CurrentValueSubject<Room?, Never> { get }

    func connectRoom(roomNumber: String)
    func disconnectRoom()
    
    func postRecording(_ record: Data) async throws -> Bool
    func postResetGame() async throws -> Bool
}
