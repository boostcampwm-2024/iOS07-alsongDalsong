import ASEntity
import ASRepositoryProtocol
import Combine
import Foundation

public final class GameStateRepository: GameStateRepositoryProtocol {
    private var mainRepository: MainRepositoryProtocol

    public init(mainRepository: MainRepositoryProtocol) {
        self.mainRepository = mainRepository
    }

    public func getGameState() -> AnyPublisher<ASEntity.GameState?, Never> {
        mainRepository.room
            .receive(on: DispatchQueue.main)
            .compactMap { room in
                guard let mode = room?.mode, let players = room?.players else { return nil }
                return ASEntity.GameState(mode: mode, recordOrder: room?.recordOrder, status: room?.status, round: room?.round, players: players)
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
