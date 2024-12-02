import ASEntity
import ASRepositoryProtocol
import Combine
import Foundation

public final class SubmitsRepository: SubmitsRepositoryProtocol {
    private var mainRepository: MainRepositoryProtocol

    public init(mainRepository: MainRepositoryProtocol) {
        self.mainRepository = mainRepository
    }

    public func getSubmits() -> AnyPublisher<[Answer], Never> {
        mainRepository.room
            .receive(on: DispatchQueue.main)
            .compactMap { $0?.submits }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    public func getSubmitsCount() -> AnyPublisher<Int, Never> {
        getSubmits()
            .map(\.count)
            .eraseToAnyPublisher()
    }

    public func submitAnswer(answer: Music) async throws -> Bool {
        try await mainRepository.submitAnswer(answer: answer)
    }
}
