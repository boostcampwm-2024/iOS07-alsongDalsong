import ASRepositoryProtocol
import Combine
import Foundation

public final class MusicRepository: MusicRepositoryProtocol {
    private let mainRepository: MainRepositoryProtocol

    public init(
        mainRepository: MainRepositoryProtocol
    ) {
        self.mainRepository = mainRepository
    }

    public func getMusicData(url: URL) async throws -> Data? {
        try await mainRepository.getResource(url: url)
    }
}
