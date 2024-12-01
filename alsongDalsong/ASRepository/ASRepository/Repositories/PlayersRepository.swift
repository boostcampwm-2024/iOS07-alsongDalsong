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
        mainRepository.room
            .receive(on: DispatchQueue.main)
            .compactMap { $0?.players }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    public func getPlayersCount() -> AnyPublisher<Int, Never> {
        self.getPlayers()
            .map { $0.count }
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
        self.getHost()
            .map { $0.id == ASFirebaseAuth.myID }
            .eraseToAnyPublisher()
    }
}

