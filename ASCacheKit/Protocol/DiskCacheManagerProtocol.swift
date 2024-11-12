import Foundation

public protocol DiskCacheManagerProtocol {
    func getData(forKey key: String) -> Data?
    func saveData(_ data: Data, forKey key: String)
    func clearCache()
}
