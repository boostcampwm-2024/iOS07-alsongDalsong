import ASDecoder
import ASEncoder
import ASEntity
import ASNetworkKit
import Combine
import Foundation

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
    
    public func getMyAnswer() -> AnyPublisher<Answer?, Never> {
        mainRepository.answers
            .receive(on: DispatchQueue.main)
            .compactMap(\.self)
            .flatMap { answers in
                // TODO: - myId를 (저장해 두었다가 또는 가져와서) 필터링 필요
                Just(answers.first /* { $0.player?.id == "myId"}*/ )
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    public func submitMusic(answer: ASEntity.Music) async throws -> Bool {
        let queryItems = [URLQueryItem(name: "userId", value: ASFirebaseAuth.myID),
                          URLQueryItem(name: "roomNumber", value: mainRepository.number.value)]
        let endPoint = FirebaseEndpoint(path: .submitMusic, method: .post)
            .update(\.queryItems, with: queryItems)
            .update(\.headers, with: ["Content-Type": "application/json"])
        
        let body = try ASEncoder.encode(answer)
//        let encoder = JSONEncoder()
//        encoder.outputFormatting = [.prettyPrinted]
//        let body = try encoder.encode(answer)
//        if let jsonString = String(data: body, encoding: .utf8) {
//            print(jsonString)
//        }
        try print(JSONSerialization.jsonObject(with: body, options: []))
        
        let response = try await networkManager.sendRequest(to: endPoint, body: body, option: .none)
        
        let responseDict = try ASDecoder.decode([String: String].self, from: response)
        return !responseDict.isEmpty
    }
}
