import ASCacheKitProtocol
import ASContainer

public struct NetworkAssembly: Assembly {
    public func assemble(container: Registerable) {
        container.register(ASNetworkManagerProtocol.self) { r in
            let cacheManager = r.resolve(CacheManagerProtocol.self)
            return ASNetworkManager(cacheManager: cacheManager)
        }
        
        container.register(ASFirebaseAuthProtocol.self, ASFirebaseAuth())
        container.register(ASFirebaseDatabaseProtocol.self, ASFirebaseDatabase())
        container.register(ASFirebaseStorageProtocol.self, ASFirebaseStorage())
    }
}
