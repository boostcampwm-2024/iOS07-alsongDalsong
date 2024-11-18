import ASCacheKit
import ASCacheKitProtocol
import Foundation

class ASCacheKitDemoViewModel: ObservableObject {
    private var cacheManager = ASCacheManager()
    private let imageURL = URL(string: "https://picsum.photos/id/13/600/600")!
    @Published var imageData: Data?

    @MainActor
    func loadCacheData(at cacheOption: CacheOption) {
        Task {
            imageData = await cacheManager.loadCache(from: imageURL, cacheOption: cacheOption)
        }
    }

    func clearCache(at cacheOption: CacheOption) {
        switch cacheOption {
            case .onlyMemory:
                cacheManager.clearMemoryCache()
            case .onlyDisk:
                cacheManager.clearDiskCache()
            case .both:
                cacheManager.clearMemoryCache()
                cacheManager.clearDiskCache()
            default: break
        }
    }
}
