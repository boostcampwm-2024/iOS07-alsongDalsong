import Foundation

public protocol CacheManagerProtocol {
    func loadCache(from url: URL, cacheOption: CacheOption) async -> Data?
    func saveCache(withKey url: URL, data: Data, cacheOption: CacheOption)
}
