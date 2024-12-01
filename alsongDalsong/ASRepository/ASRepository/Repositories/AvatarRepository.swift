import ASRepositoryProtocol
import Combine
import Foundation

public final class AvatarRepository: AvatarRepositoryProtocol {
    private let mainRepository: MainRepositoryProtocol
    
    public init(
        mainRepository: MainRepositoryProtocol
    ) {
        self.mainRepository = mainRepository
    }
    
    public func getAvatarUrls() async throws -> [URL] {
        do {
            let urls = try await self.mainRepository.getAvatarUrls()
            return urls
        } catch {
            throw error
        }
    }
    
    public func getAvatarData(url: URL) async -> Data? {
        do {
            return try await mainRepository.getResource(url: url)
        } catch {
            return nil
        }
    }
}
