import Foundation
import Combine
import ASEntity

public struct SubmitsRepository: SubmitsRepositoryProtocol {
    private var mainRepository: MainRepository
    
    init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
    }
    
    public func getSubmits() -> AnyPublisher<[Answer], Never> {
        mainRepository.$answers
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
}
