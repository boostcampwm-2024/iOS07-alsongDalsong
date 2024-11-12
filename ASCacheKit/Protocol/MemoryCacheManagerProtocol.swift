import Foundation

public protocol MemoryCacheManagerProtocol {
    func getObject(forKey key: String) -> AnyObject?
    func setObject(_ object: AnyObject, forKey key: String)
    func clearCache()
}