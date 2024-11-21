import ASNetworkKit
import Combine
import Foundation

public final class AvatarRepository: AvatarRepositoryProtocol {
    // TODO: - Container로 주입
    private let firebaseManager: ASFirebaseManager
    private let networkManager: ASNetworkManager
    
    public init (
        firebaseManager: ASFirebaseManager,
        networkManager: ASNetworkManager
    ) {
        self.firebaseManager = firebaseManager
        self.networkManager = networkManager
    }
    
    public func getAvatarUrls() -> Future<[URL], Error> {
        Future { promise in
            Task {
                do {
                    let urls = try await self.firebaseManager.getAvatarUrls()
                    promise(.success(urls))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
    
    public func getAvatarData(url: URL) -> Future<Data?, Error> {
        Future { promise in
            Task {
                do {
                    guard let endpoint = ResourceEndpoint(url: url) else { return promise(.failure(ASNetworkErrors.urlError)) }
                    let data = try await self.networkManager.sendRequest(to: endpoint)
                    promise(.success(data))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
}
