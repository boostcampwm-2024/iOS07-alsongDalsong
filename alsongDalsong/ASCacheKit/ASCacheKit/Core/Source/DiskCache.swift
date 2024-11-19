import Foundation
import ASCacheKitProtocol

struct DiskCacheManager: @unchecked Sendable, DiskCacheManagerProtocol {
    private let fileManager = FileManager.default
    let cacheDirectory: URL

    init() {
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = cachesDirectory.appendingPathComponent("MediaDiskCache")
        createCacheDirectory()
    }
    
    private func createCacheDirectory() {
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        }
    }

    func getData(forKey key: String) -> Data? {
        let fileURL = cacheDirectory.appendingPathComponent(key.sha256)
        return try? Data(contentsOf: fileURL)
    }

    func saveData(_ data: Data, forKey key: String) {
        let fileURL = cacheDirectory.appendingPathComponent(key.sha256)
        try? data.write(to: fileURL)
    }

    func clearCache() {
        if let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil) {
            for fileURL in files {
                try? fileManager.removeItem(at: fileURL)
            }
        }
    }
}
