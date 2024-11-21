import Foundation
import ASCacheKitProtocol

public protocol ASNetworkManagerProtocol {
    func sendRequest(to endpoint: any Endpoint, body: Data?, option: CacheOption) async throws -> Data
}
