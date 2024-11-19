import Foundation
import Combine
import ASEntity

public struct AnswersRepository: AnswersRepositoryProtocol {
    private var mainRepository: MainRepository
    
    init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
    }
    
    public func getAnswers() -> AnyPublisher<[Answer], Never> {
        mainRepository.$answers
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
}
