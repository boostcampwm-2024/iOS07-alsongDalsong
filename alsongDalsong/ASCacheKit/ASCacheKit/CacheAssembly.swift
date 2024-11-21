import ASCacheKitProtocol
import ASContainer

public struct CacheAssembly: Assembly {
    public init() {}

    public func assemble(container: Registerable) {
        container.registerSingleton(CacheManagerProtocol.self, ASCacheManager())
    }
}
