import UIKit

internal final class MemoryCacheManager: MemoryCacheManagerProtocol {
    private let cache = NSCache<NSString, AnyObject>()

    func getObject(forKey key: String) -> AnyObject? {
        return cache.object(forKey: key as NSString)
    }

    func setObject(_ object: AnyObject, forKey key: String) {
        cache.setObject(object, forKey: key as NSString)
    }

    func clearCache() {
        cache.removeAllObjects()
    }
}
