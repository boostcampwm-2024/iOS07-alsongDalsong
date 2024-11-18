import ASCacheKitProtocol
import Foundation

final class MockDiskCacheManager: DiskCacheManagerProtocol {
    private var mockStorage: [String: Data] = [:]

    func getData(forKey key: String) -> Data? {
        return mockStorage[key]
    }

    func saveData(_ data: Data, forKey key: String) {
        mockStorage[key] = data
    }

    func clearCache() {
        mockStorage.removeAll()
    }
}
