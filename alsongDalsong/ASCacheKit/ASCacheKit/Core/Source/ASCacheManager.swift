import ASCacheKitProtocol
import Foundation

public struct ASCacheManager {
    public let memoryCache: MemoryCacheManagerProtocol
    public let diskCache: DiskCacheManagerProtocol
    public let urlSession: URLSessionProtocol

    public init() {
        memoryCache = MemoryCacheManager()
        diskCache = DiskCacheManager()
        urlSession = URLSession.shared
    }

    public init(memoryCache: MemoryCacheManagerProtocol, diskCache: DiskCacheManagerProtocol, session: URLSessionProtocol) {
        self.memoryCache = memoryCache
        self.diskCache = diskCache
        urlSession = session
    }

    public func loadCache(from url: URL, cacheOption: CacheOption) async -> Data? {
        let cacheKey = url.absoluteString
        return await loadData(forKey: cacheKey, cacheOption: cacheOption)
    }

    private func loadData(forKey key: String, cacheOption: CacheOption) async -> Data? {
        switch cacheOption {
            case .onlyMemory:
                return await loadFromMemory(forKey: key)
            case .onlyDisk:
                return await loadFromDisk(forKey: key)
            case .both:
                if let cachedData = await loadFromMemory(forKey: key) {
                    return cachedData
                }
                if let diskData = await loadFromDisk(forKey: key) {
                    return diskData
                }
                return await downloadData(from: key)
            default:
                return nil
        }
    }

    private func loadFromMemory(forKey key: String) async -> Data? {
        return memoryCache.getObject(forKey: key) as? Data
    }

    private func loadFromDisk(forKey key: String) async -> Data? {
        if let diskData = diskCache.getData(forKey: key) {
            memoryCache.setObject(diskData as NSData, forKey: key)
            return diskData
        }
        return nil
    }

    private func downloadData(from url: String) async -> Data? {
        do {
            let (data, _) = try await urlSession.data(from: URL(string: url)!)
            memoryCache.setObject(data as NSData, forKey: url)
            diskCache.saveData(data, forKey: url)
            return data
        } catch {
            print("Failed to load data from URL:", error)
            return nil
        }
    }

    public func clearMemoryCache() {
        memoryCache.clearCache()
    }

    public func clearDiskCache() {
        diskCache.clearCache()
    }
}
