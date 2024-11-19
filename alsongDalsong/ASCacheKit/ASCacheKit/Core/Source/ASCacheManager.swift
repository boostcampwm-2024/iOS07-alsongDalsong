import ASCacheKitProtocol
import Foundation

public struct ASCacheManager: CacheManagerProtocol, Sendable {
    public let memoryCache: MemoryCacheManagerProtocol
    public let diskCache: DiskCacheManagerProtocol

    public init() {
        memoryCache = MemoryCacheManager()
        diskCache = DiskCacheManager()
    }

    public init(memoryCache: MemoryCacheManagerProtocol, diskCache: DiskCacheManagerProtocol) {
        self.memoryCache = memoryCache
        self.diskCache = diskCache
    }

    public func loadCache(from url: URL, cacheOption: CacheOption) -> Data? {
        let cacheKey = url.absoluteString
        return loadData(forKey: cacheKey, cacheOption: cacheOption)
    }

    public func saveCache(withKey url: URL, data: Data, cacheOption: CacheOption) {
        let cacheKey = url.absoluteString
        switch cacheOption {
            case .onlyMemory:
                memoryCache.setObject(data as NSData, forKey: cacheKey)
            case .onlyDisk:
                diskCache.saveData(data, forKey: cacheKey)
            case .both:
                memoryCache.setObject(data as NSData, forKey: cacheKey)
                diskCache.saveData(data, forKey: cacheKey)
            default: break
        }
    }

    private func loadData(forKey key: String, cacheOption: CacheOption) -> Data? {
        switch cacheOption {
            case .onlyMemory:
                return loadFromMemory(forKey: key)
            case .onlyDisk:
                return loadFromDisk(forKey: key)
            case .both:
                if let cachedData = loadFromMemory(forKey: key) {
                    return cachedData
                }
                if let diskData = loadFromDisk(forKey: key) {
                    return diskData
                }
                return nil
            default:
                return nil
        }
    }

    private func loadFromMemory(forKey key: String) -> Data? {
        return memoryCache.getObject(forKey: key) as? Data
    }

    private func loadFromDisk(forKey key: String) -> Data? {
        if let diskData = diskCache.getData(forKey: key) {
            memoryCache.setObject(diskData as NSData, forKey: key)
            return diskData
        }
        return nil
    }

    public func clearMemoryCache() {
        memoryCache.clearCache()
    }

    public func clearDiskCache() {
        diskCache.clearCache()
    }
}
