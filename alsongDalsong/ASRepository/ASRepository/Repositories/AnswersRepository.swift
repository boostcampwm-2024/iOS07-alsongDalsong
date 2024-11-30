import ASDecoder
import ASEncoder
import ASEntity
import ASNetworkKit
import Combine
import Foundation
import ASRepositoryProtocol

public final class AnswersRepository: AnswersRepositoryProtocol {
    private var mainRepository: MainRepositoryProtocol
    private var networkManager: ASNetworkManagerProtocol
    public init(mainRepository: MainRepositoryProtocol, networkManager: ASNetworkManagerProtocol) {
        self.mainRepository = mainRepository
        self.networkManager = networkManager
    }

    public func getAnswers() -> AnyPublisher<[Answer], Never> {
        mainRepository.answers
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    public func getAnswersCount() -> AnyPublisher<Int, Never> {
        mainRepository.answers
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .map { $0.count }
            .eraseToAnyPublisher()
    }

    public func getMyAnswer() -> AnyPublisher<Answer?, Never> {
        guard let myId = mainRepository.myId else {
            return Just(nil).eraseToAnyPublisher()
        }

        return mainRepository.answers
            .receive(on: DispatchQueue.main)
            .compactMap(\.self)
            .flatMap { answers in
                Just(answers.first { $0.player?.id == myId })
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    public func submitMusic(answer: ASEntity.Music) async throws -> Bool {
        let queryItems = [URLQueryItem(name: "userId", value: ASFirebaseAuth.myID),
                          URLQueryItem(name: "roomNumber", value: mainRepository.number.value)]
        let endPoint = FirebaseEndpoint(path: .submitMusic, method: .post)
            .update(\.queryItems, with: queryItems)

        let body = try ASEncoder.encode(answer)
        let response = try await networkManager.sendRequest(to: endPoint, type: .json, body: body, option: .none)
        let responseDict = try ASDecoder.decode([String: String].self, from: response)
        return !responseDict.isEmpty
    }
}
