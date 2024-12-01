import Foundation
import Combine
import ASEntity
import ASRepositoryProtocol

public final class SelectedRecordsRepository: SelectedRecordsRepositoryProtocol {
    private var mainRepository: MainRepositoryProtocol
    
    public init(mainRepository: MainRepositoryProtocol) {
        self.mainRepository = mainRepository
    }
    
    public func getSelectedRecords() -> AnyPublisher<[UInt8], Never> {
        mainRepository.room
            .receive(on: DispatchQueue.main)
            .compactMap { $0?.selectedRecords }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}

