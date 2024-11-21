import Foundation
import Combine
import ASEntity

public final class RecordsRepository: RecordsRepositoryProtocol {
    private var mainRepository: MainRepository
    
    public init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
    }
    
    public func getRecords() -> AnyPublisher<[ASEntity.Record], Never> {
        mainRepository.$records
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
}
