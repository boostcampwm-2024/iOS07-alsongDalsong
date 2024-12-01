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
        mainRepository.room
            .receive(on: DispatchQueue.main)
            .compactMap { $0?.status }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    public func getRound() -> AnyPublisher<UInt8, Never> {
        mainRepository.room
            .receive(on: DispatchQueue.main)
            .compactMap { $0?.round }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    public func getRecordOrder() -> AnyPublisher<UInt8, Never> {
        mainRepository.room
            .receive(on: DispatchQueue.main)
            .compactMap { $0?.recordOrder }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    public func getDueTime() -> AnyPublisher<Date, Never> {
        mainRepository.room
            .receive(on: DispatchQueue.main)
            .compactMap { $0?.dueTime }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
