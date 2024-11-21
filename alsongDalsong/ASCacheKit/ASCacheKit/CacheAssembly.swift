import ASContainer
import ASCacheKitProtocol

public struct CacheAssembly: Assembly {
    public init() {}
    
    public func assemble(container: Registerable) {
        container.registerSingleton(CacheManagerProtocol.self, ASCacheManager())
    }
}
