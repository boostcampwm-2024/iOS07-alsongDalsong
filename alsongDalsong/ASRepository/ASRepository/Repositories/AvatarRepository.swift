import ASNetworkKit
import Combine
import Foundation
import ASRepositoryProtocol

public final class AvatarRepository: AvatarRepositoryProtocol {
    // TODO: - Container로 주입
    private let storageManager: ASFirebaseStorageProtocol
    
    public init (
        storageManager: ASFirebaseStorageProtocol
    ) {
        self.storageManager = storageManager
    }
    
    public func getAvatarUrls() async throws -> [URL] {
        do {
            let urls = try await self.storageManager.getAvatarUrls()
            return urls
        } catch {
            throw error
        }
    }
}
