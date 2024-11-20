import ASNetworkKit
import Combine
import Foundation

public final class AvatarRepository: AvatarRepositoryProtocol {
    // TODO: - Container로 주입
    private let firebaseManager: ASFirebaseStorageProtocol
    private let networkManager: ASNetworkManagerProtocol
    
    public init (
        firebaseManager: ASFirebaseStorageProtocol,
        networkManager: ASNetworkManagerProtocol
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
                    guard let endpoint = ImageEndpoint(url: url) else { return promise(.failure(ASNetworkErrors.urlError)) }
                    let data = try await self.networkManager.sendRequest(to: endpoint, body: nil, option: .both)
                    promise(.success(data))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
}
