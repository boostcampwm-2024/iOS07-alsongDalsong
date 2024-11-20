import Foundation
import Combine
import ASEntity

public struct SelectedRecordsRepository: SelectedRecordsRepositoryProtocol {
    private var mainRepository: MainRepository
    
    public init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
    }
    
    public func getSelectedRecords() -> AnyPublisher<[UInt8], Never> {
        mainRepository.$selectedRecords
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
}

