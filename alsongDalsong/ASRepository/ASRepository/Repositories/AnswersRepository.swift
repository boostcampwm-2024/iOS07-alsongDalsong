import ASEntity
import ASRepositoryProtocol
import Combine
import Foundation

public final class AnswersRepository: AnswersRepositoryProtocol {
    private var mainRepository: MainRepositoryProtocol

    public init(mainRepository: MainRepositoryProtocol) {
        self.mainRepository = mainRepository
    }

    public func getAnswers() -> AnyPublisher<[Answer], Never> {
        mainRepository.room
            .receive(on: DispatchQueue.main)
            .compactMap { $0?.answers }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    public func getAnswersCount() -> AnyPublisher<Int, Never> {
        mainRepository.room
            .receive(on: DispatchQueue.main)
            .compactMap { $0?.answers }
            .map(\.count)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    public func getMyAnswer() -> AnyPublisher<Answer?, Never> {
        guard let myId = mainRepository.myId else {
            return Just(nil).eraseToAnyPublisher()
        }

        return mainRepository.room
            .receive(on: DispatchQueue.main)
            .compactMap { $0?.answers }
            .removeDuplicates()
            .flatMap { answers in
                Just(answers.first { $0.player?.id == myId })
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    public func submitMusic(answer: ASEntity.Music) async throws -> Bool {
        try await mainRepository.submitMusic(answer: answer)
    }
}
