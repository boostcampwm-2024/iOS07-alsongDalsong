import ASNetworkKit
import Combine
import Foundation
import ASRepositoryProtocol

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

    public func getMusicData(url: URL) async -> Data? {
        do {
            guard let endpoint = ResourceEndpoint(url: url) else { return nil }
            let data = try await self.networkManager.sendRequest(to: endpoint, type: .json, body: nil, option: .both)
            return data
        } catch {
            return nil
        }
    }
}
