import Foundation
import Combine
import ASEntity

public struct PlayersRepository: PlayersRepositoryProtocol {
    private var mainRepository: MainRepository
    
    public init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
    }
    
    public func getPlayers() -> AnyPublisher<[Player], Never> {
        mainRepository.$players
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    public func getHost() -> AnyPublisher<Player, Never> {
        mainRepository.$host
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
}

