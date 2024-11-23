import Foundation
import Combine
import ASEntity

public final class AnswersRepository: AnswersRepositoryProtocol {
    private var mainRepository: MainRepositoryProtocol
    
    public init(mainRepository: MainRepositoryProtocol) {
        self.mainRepository = mainRepository
    }
    
    public func getAnswers() -> AnyPublisher<[Answer], Never> {
        mainRepository.answers
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    public func getMyAnswer() -> AnyPublisher<Answer?, Never> {
        mainRepository.answers
            .receive(on: DispatchQueue.main)
            .compactMap(\.self)
            .flatMap { answers in
                // TODO: - myId를 (저장해 두었다가 또는 가져와서) 필터링 필요
                return Just(answers.first/* { $0.player?.id == "myId"}*/)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
