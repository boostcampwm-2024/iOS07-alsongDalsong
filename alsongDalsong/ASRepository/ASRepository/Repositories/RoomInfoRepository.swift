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
        mainRepository.room
            .receive(on: DispatchQueue.main)
            .compactMap { $0?.number }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    public func getMode() -> AnyPublisher<Mode, Never> {
        mainRepository.room
            .receive(on: DispatchQueue.main)
            .compactMap { $0?.mode }
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
}
