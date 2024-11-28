import ASNetworkKit
import Combine
import Foundation

public final class AvatarRepository: AvatarRepositoryProtocol {
    // TODO: - Container로 주입
    private let storageManager: ASFirebaseStorageProtocol
    private let networkManager: ASNetworkManagerProtocol
    
    public init (
        storageManager: ASFirebaseStorageProtocol,
        networkManager: ASNetworkManagerProtocol
    ) {
        self.storageManager = storageManager
        self.networkManager = networkManager
    }
    
    public func getAvatarUrls() async throws -> [URL] {
        do {
            let urls = try await self.storageManager.getAvatarUrls()
            return urls
        } catch {
            throw error
        }
    }
    
    public func getAvatarData(url: URL) async -> Data? {
        do {
            guard let endpoint = ResourceEndpoint(url: url)
            else { return nil }
            let data = try await self.networkManager.sendRequest(to: endpoint, type: .json, body: nil, option: .both)
            return data
        } catch {
            return nil
        }
    }
}
