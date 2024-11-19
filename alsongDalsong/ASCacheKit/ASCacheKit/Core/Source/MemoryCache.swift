import Foundation
import ASCacheKitProtocol

struct MemoryCacheManager: @unchecked Sendable, MemoryCacheManagerProtocol {
    private let cache = NSCache<NSString, AnyObject>()

    func getObject(forKey key: String) -> AnyObject? {
        return cache.object(forKey: key.sha256 as NSString)
    }

    func setObject(_ object: AnyObject, forKey key: String) {
        cache.setObject(object, forKey: key.sha256 as NSString)
    }

    func clearCache() {
        cache.removeAllObjects()
    }
}

