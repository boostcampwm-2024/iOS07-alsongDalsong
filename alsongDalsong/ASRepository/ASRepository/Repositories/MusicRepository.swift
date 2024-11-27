import ASNetworkKit
import Combine
import Foundation

public final class MusicRepository: MusicRepositoryProtocol {
    // TODO: - Container로 주입
    private let firebaseManager: ASFirebaseStorageProtocol
    private let networkManager: ASNetworkManagerProtocol

    public init(
        firebaseManager: ASFirebaseStorageProtocol,
        networkManager: ASNetworkManagerProtocol
    ) {
        self.firebaseManager = firebaseManager
        self.networkManager = networkManager
    }

    public func getMusicData(url: URL) -> Future<Data?, Error> {
        Future { promise in
            Task {
                do {
                    guard let endpoint = ResourceEndpoint(url: url)
                    else { return promise(.failure(ASNetworkErrors.urlError)) }
                    let data = try await self.networkManager.sendRequest(
                        to: endpoint,
                        type: .json,
                        body: nil,
                        option: .both
                    )
                    promise(.success(data))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
}
