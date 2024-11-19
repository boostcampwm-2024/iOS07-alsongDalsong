import Foundation

public protocol CacheManagerProtocol {
    func loadCache(from url: URL, cacheOption: CacheOption) -> Data?
    func saveCache(withKey url: URL, data: Data, cacheOption: CacheOption)
}
