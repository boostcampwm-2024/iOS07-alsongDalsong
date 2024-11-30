import Foundation
import Combine
import ASEntity
import ASRepositoryProtocol

public final class GameStatusRepository: GameStatusRepositoryProtocol {
    private var mainRepository: MainRepositoryProtocol
    
    public init(mainRepository: MainRepositoryProtocol) {
        self.mainRepository = mainRepository
    }
    
    public func getStatus() -> AnyPublisher<Status?, Never> {
        mainRepository.status
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    public func getRound() -> AnyPublisher<UInt8, Never> {
        mainRepository.round
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    public func getRecordOrder() -> AnyPublisher<UInt8, Never> {
        mainRepository.recordOrder
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    public func getDueTime() -> AnyPublisher<Date, Never> {
        mainRepository.dueTime
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
}
