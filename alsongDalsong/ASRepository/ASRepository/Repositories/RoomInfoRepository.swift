import Foundation
import Combine
import ASEntity

public struct RoomInfoRepository: RoomInfoRepositoryProtocol {
    private var mainRepository: MainRepository
    
    public init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
    }
    
    public func getRoomNumber() -> AnyPublisher<String, Never> {
        mainRepository.$number
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    public func getMode() -> AnyPublisher<Mode, Never> {
        mainRepository.$mode
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
}
