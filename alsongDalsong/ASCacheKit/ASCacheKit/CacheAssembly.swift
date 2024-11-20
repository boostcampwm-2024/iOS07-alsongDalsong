import ASContainer
import ASCacheKitProtocol

public struct CacheAssembly: Assembly {
    public init() {}
    
    public func assemble(container: Registerable) {
        container.register(CacheManagerProtocol.self, ASCacheManager())
    }
}
