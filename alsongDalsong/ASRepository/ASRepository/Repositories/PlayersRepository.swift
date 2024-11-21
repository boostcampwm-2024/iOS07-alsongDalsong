import Foundation
import Combine
import ASEntity

public final class PlayersRepository: PlayersRepositoryProtocol {
    private var mainRepository: MainRepositoryProtocol
    
    public init(mainRepository: MainRepositoryProtocol) {
        self.mainRepository = mainRepository
    }
    
    public func getPlayers() -> AnyPublisher<[Player], Never> {
        mainRepository.players
            .receive(on: DispatchQueue.main)
            .compactMap { [weak self] players in
                print(players)
                print(self?.mainRepository)
                
                return players
            }
            .eraseToAnyPublisher()
    }
    
    public func getHost() -> AnyPublisher<Player, Never> {
        mainRepository.host
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
}

