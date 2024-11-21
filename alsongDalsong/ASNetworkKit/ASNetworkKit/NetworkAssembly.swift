import ASCacheKitProtocol
import ASContainer

public struct NetworkAssembly: Assembly {
    public init() {}
    
    public func assemble(container: Registerable) {
        container.registerSingleton(ASNetworkManagerProtocol.self) { r in
            let cacheManager = r.resolve(CacheManagerProtocol.self)
            return ASNetworkManager(cacheManager: cacheManager)
        }
        
        container.registerSingleton(ASFirebaseAuthProtocol.self, ASFirebaseAuth())
        container.registerSingleton(ASFirebaseDatabaseProtocol.self, ASFirebaseDatabase())
        container.registerSingleton(ASFirebaseStorageProtocol.self, ASFirebaseStorage())
    }
}
