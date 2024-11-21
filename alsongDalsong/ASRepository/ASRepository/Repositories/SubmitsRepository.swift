import Foundation
import Combine
import ASEntity

public final class SubmitsRepository: SubmitsRepositoryProtocol {
    private var mainRepository: MainRepositoryProtocol
    
    public init(mainRepository: MainRepositoryProtocol) {
        self.mainRepository = mainRepository
    }
    
    public func getSubmits() -> AnyPublisher<[Answer], Never> {
        mainRepository.answers
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
}
