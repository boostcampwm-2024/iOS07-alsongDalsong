import Foundation
import Combine
import ASEntity
import ASRepositoryProtocol

public final class RoomInfoRepository: RoomInfoRepositoryProtocol {
    private var mainRepository: MainRepositoryProtocol
    
    public init(mainRepository: MainRepositoryProtocol) {
        self.mainRepository = mainRepository
    }
    
    public func getRoomNumber() -> AnyPublisher<String, Never> {
        mainRepository.number
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    public func getMode() -> AnyPublisher<Mode, Never> {
        mainRepository.mode
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
}
