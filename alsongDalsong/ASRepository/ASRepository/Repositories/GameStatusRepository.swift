import Foundation
import Combine
import ASEntity

public struct GameStatusRepository: GameStatusRepositoryProtocol {
    private var mainRepository: MainRepository
    
    public init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
    }
    
    public func getStatus() -> AnyPublisher<Status, Never> {
        mainRepository.$status
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    public func getRound() -> AnyPublisher<UInt8, Never> {
        mainRepository.$round
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    public func getDueTime() -> AnyPublisher<Date, Never> {
        mainRepository.$dueTime
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
}
