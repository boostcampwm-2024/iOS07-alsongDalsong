import ASEntity
import Combine
import Foundation

public protocol AnswersRepositoryProtocol {
    func getAnswers() -> AnyPublisher<[Answer], Never>
}

public protocol GameStatusRepositoryProtocol {
    func getStatus() -> AnyPublisher<Status, Never>
    func getRound() -> AnyPublisher<UInt8, Never>
    func getDueTime() -> AnyPublisher<Date, Never>
}

public protocol PlayersRepositoryProtocol {
    func getPlayers() -> AnyPublisher<[Player], Never>
    func getHost() -> AnyPublisher<Player, Never>
}

public protocol RecordsRepositoryProtocol {
    func getRecords() -> AnyPublisher<[ASEntity.Record], Never>
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
}