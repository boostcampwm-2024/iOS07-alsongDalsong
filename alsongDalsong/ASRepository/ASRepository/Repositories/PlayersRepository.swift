import Foundation
import ASNetworkKit
import Combine
import ASEntity
import ASRepositoryProtocol

public final class PlayersRepository: PlayersRepositoryProtocol {
    private var mainRepository: MainRepositoryProtocol
    private var firebaseAuthManager: ASFirebaseAuthProtocol
    
    public init(mainRepository: MainRepositoryProtocol,
                firebaseAuthManager: ASFirebaseAuthProtocol) {
        self.mainRepository = mainRepository
        self.firebaseAuthManager = firebaseAuthManager
    }
    
    public func getPlayers() -> AnyPublisher<[Player], Never> {
        mainRepository.players
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    public func getPlayersCount() -> AnyPublisher<Int, Never> {
        mainRepository.players
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .map { $0.count }
            .eraseToAnyPublisher()
    }
    
    public func getHost() -> AnyPublisher<Player, Never> {
        mainRepository.host
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    public func isHost() -> AnyPublisher<Bool, Never> {
        self.getHost()
            .receive(on: DispatchQueue.main)
            .map { $0.id == ASFirebaseAuth.myID }
            .eraseToAnyPublisher()
    }
}

