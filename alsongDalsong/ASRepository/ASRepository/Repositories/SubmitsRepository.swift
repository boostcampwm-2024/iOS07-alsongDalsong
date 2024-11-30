import ASDecoder
import ASEncoder
import ASEntity
import ASNetworkKit
import Combine
import Foundation
import ASRepositoryProtocol

public final class SubmitsRepository: SubmitsRepositoryProtocol {
    private var mainRepository: MainRepositoryProtocol
    private var networkManager: ASNetworkManagerProtocol

    public init(mainRepository: MainRepositoryProtocol, networkManager: ASNetworkManagerProtocol) {
        self.mainRepository = mainRepository
        self.networkManager = networkManager
    }

    public func getSubmits() -> AnyPublisher<[Answer], Never> {
        mainRepository.answers
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    public func getSubmitsCount() -> AnyPublisher<Int, Never> {
        mainRepository.submits
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .map { $0.count }
            .eraseToAnyPublisher()
    }
    
    public func submitAnswer(answer: Music) async throws -> Bool {
        let queryItems = [URLQueryItem(name: "userId", value: ASFirebaseAuth.myID),
                          URLQueryItem(name: "roomNumber", value: mainRepository.number.value)]
        let endPoint = FirebaseEndpoint(path: .submitAnswer, method: .post)
            .update(\.queryItems, with: queryItems)
            .update(\.headers, with: ["Content-Type": "application/json"])

        let body = try ASEncoder.encode(answer)
        let response = try await networkManager.sendRequest(to: endPoint, type: .json, body: body, option: .none)
        let responseDict = try ASDecoder.decode([String: String].self, from: response)
        return !responseDict.isEmpty
    }
}
