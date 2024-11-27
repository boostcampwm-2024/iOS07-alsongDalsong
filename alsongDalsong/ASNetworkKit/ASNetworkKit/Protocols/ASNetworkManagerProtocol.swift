import ASCacheKitProtocol
import Foundation

public protocol ASNetworkManagerProtocol {
    func sendRequest(to endpoint: any Endpoint, type: HTTPContentType, body: Data?, option: CacheOption) async throws -> Data
}
