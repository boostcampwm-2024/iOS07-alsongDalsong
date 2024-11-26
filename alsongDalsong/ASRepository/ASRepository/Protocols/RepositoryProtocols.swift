import ASEntity
import Combine
import Foundation

public protocol AnswersRepositoryProtocol {
    func getAnswers() -> AnyPublisher<[Answer], Never>
    func getMyAnswer() -> AnyPublisher<Answer?, Never>
    func submitMusic(answer: ASEntity.Music) async throws -> Bool
}

public protocol GameStatusRepositoryProtocol {
    func getStatus() -> AnyPublisher<Status, Never>
    func getRound() -> AnyPublisher<UInt8, Never>
    func getRecordOrder() -> AnyPublisher<UInt8, Never>
    func getDueTime() -> AnyPublisher<Date, Never>
}

public protocol PlayersRepositoryProtocol {
    func getPlayers() -> AnyPublisher<[Player], Never>
    func getHost() -> AnyPublisher<Player, Never>
    func isHost() -> AnyPublisher<Bool, Never>
}

public protocol RecordsRepositoryProtocol {
    func getRecords() -> AnyPublisher<[ASEntity.Record], Never>
    func getHumming(on recordOrder: UInt8) -> AnyPublisher<ASEntity.Record?, Never>
}

public protocol RoomInfoRepositoryProtocol {
    func getRoomNumber() -> AnyPublisher<String, Never>
    func getMode() -> AnyPublisher<Mode, Never>
}

public protocol SelectedRecordsRepositoryProtocol {
    func getSelectedRecords() -> AnyPublisher<[UInt8], Never>
}

public protocol SubmitsRepositoryProtocol {
    func getSubmits() -> AnyPublisher<[Answer], Never>
    func submitAnswer(answer: Music) async throws -> Bool
}

public protocol AvatarRepositoryProtocol {
    func getAvatarUrls() -> Future<[URL], Error>
    func getAvatarData(url: URL) -> Future<Data?, Error>
}

public protocol RoomActionRepositoryProtocol {
    func createRoom(nickname: String, avatar: URL) async throws -> String
    func joinRoom(nickname: String, avatar: URL, roomNumber: String) async throws -> Bool
    func leaveRoom() async throws -> Bool
    func startGame(roomNumber: String) async throws -> Bool
    func changeMode(roomNumber: String, mode: Mode) async throws -> Bool
}

public protocol MusicRepositoryProtocol {
    func getMusicData(url: URL) -> Future<Data?, Error>
}

public protocol HummingResultRepositoryProtocol {
    func getResult() -> AnyPublisher<[(answer: Answer, records: [ASEntity.Record], submit: Answer)], Never>
}
