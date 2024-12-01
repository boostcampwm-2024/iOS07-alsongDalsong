import ASEntity
import Combine
import Foundation

public protocol MainRepositoryProtocol {
    var myId: String? { get }
    var room: CurrentValueSubject<Room?, Never> { get }

    func connectRoom(roomNumber: String)
    func disconnectRoom()

    func createRoom(nickname: String, avatar: URL) async throws -> String
    func joinRoom(nickname: String, avatar: URL, roomNumber: String) async throws -> Bool
    func leaveRoom() async throws -> Bool
    func startGame() async throws -> Bool
    func changeMode(mode: Mode) async throws -> Bool
    func changeRecordOrder() async throws -> Bool
    func resetGame() async throws -> Bool
    func submitAnswer(answer: Music) async throws -> Bool
    func getAvatarUrls() async throws -> [URL]
    func getResource(url: URL) async throws -> Data

    func submitMusic(answer: ASEntity.Music) async throws -> Bool
    func postRecording(_ record: Data) async throws -> Bool
}
