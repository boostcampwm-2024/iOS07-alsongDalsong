import ASEntity
import ASRepositoryProtocol
import Combine
import Foundation

public final class PlayersRepository: PlayersRepositoryProtocol {
    private var mainRepository: MainRepositoryProtocol
    
    public init(mainRepository: MainRepositoryProtocol) {
        self.mainRepository = mainRepository
    }
    
    public func getPlayers() -> AnyPublisher<[Player], Never> {
        mainRepository.room
            .receive(on: DispatchQueue.main)
            .compactMap { $0?.players }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    public func getPlayersCount() -> AnyPublisher<Int, Never> {
        getPlayers()
            .map(\.count)
            .eraseToAnyPublisher()
    }
    
    public func getHost() -> AnyPublisher<Player, Never> {
        mainRepository.room
            .receive(on: DispatchQueue.main)
            .compactMap { $0?.host }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    public func isHost() -> AnyPublisher<Bool, Never> {
        getHost()
            .map { $0.id == self.mainRepository.myId }
            .eraseToAnyPublisher()
    }
}
