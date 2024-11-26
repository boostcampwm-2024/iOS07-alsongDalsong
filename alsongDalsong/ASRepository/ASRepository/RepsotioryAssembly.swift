import ASContainer
import ASNetworkKit

public struct RepsotioryAssembly: Assembly {
    public init() {}
    
    public func assemble(container: Registerable) {
        container.registerSingleton(MainRepositoryProtocol.self) { r in
            let databaseManager = r.resolve(ASFirebaseDatabaseProtocol.self)
            return MainRepository(
                databaseManager: databaseManager
            )
        }
        
        container.register(AnswersRepositoryProtocol.self) { r in
            let mainRepository = r.resolve(MainRepositoryProtocol.self)
            let networkManager = r.resolve(ASNetworkManagerProtocol.self)
            return AnswersRepository(
                mainRepository: mainRepository,
                networkManager: networkManager
            )
        }
        
        container.register(AvatarRepositoryProtocol.self) { r in
            let storageManager = r.resolve(ASFirebaseStorageProtocol.self)
            let networkManager = r.resolve(ASNetworkManagerProtocol.self)
            return AvatarRepository(
                storageManager: storageManager,
                networkManager: networkManager
            )
        }
        
        container.register(GameStatusRepositoryProtocol.self) { r in
            let mainRepository = r.resolve(MainRepositoryProtocol.self)
            return GameStatusRepository(
                mainRepository: mainRepository
            )
        }
        
        container.register(MusicRepositoryProtocol.self) { r in
            let firebaseManager = r.resolve(ASFirebaseStorageProtocol.self)
            let networkManager = r.resolve(ASNetworkManagerProtocol.self)
            return MusicRepository(
                firebaseManager: firebaseManager,
                networkManager: networkManager
            )
        }
        
        container.register(PlayersRepositoryProtocol.self) { r in
            let mainRepository = r.resolve(MainRepositoryProtocol.self)
            let firebaseAuthManager = r.resolve(ASFirebaseAuthProtocol.self)
            return PlayersRepository(
                mainRepository: mainRepository,
                firebaseAuthManager: firebaseAuthManager
            )
        }
        
        container.register(RecordsRepositoryProtocol.self) { r in
            let mainRepository = r.resolve(MainRepositoryProtocol.self)
            return RecordsRepository(
                mainRepository: mainRepository
            )
        }
        
        container.register(RoomActionRepositoryProtocol.self) { r in
            let mainRepository = r.resolve(MainRepositoryProtocol.self)
            let authManager = r.resolve(ASFirebaseAuthProtocol.self)
            let networkManager = r.resolve(ASNetworkManagerProtocol.self)
            return RoomActionRepository(
                mainRepository: mainRepository,
                authManager: authManager,
                networkManager: networkManager
            )
        }
        
        container.register(RoomInfoRepositoryProtocol.self) { r in
            let mainRepository = r.resolve(MainRepositoryProtocol.self)
            return RoomInfoRepository(
                mainRepository: mainRepository
            )
        }
        
        container.register(SelectedRecordsRepositoryProtocol.self) { r in
            let mainRepository = r.resolve(MainRepositoryProtocol.self)
            return SelectedRecordsRepository(
                mainRepository: mainRepository
            )
        }
        
        container.register(SubmitsRepositoryProtocol.self) { r in
            let mainRepository = r.resolve(MainRepositoryProtocol.self)
            let networkManager = r.resolve(ASNetworkManagerProtocol.self)
            return SubmitsRepository(
                mainRepository: mainRepository,
                networkManager: networkManager
            )
        }
        
        container.register(HummingResultRepositoryProtocol.self) { r in
            let mainRepository = r.resolve(MainRepositoryProtocol.self)
            let storageManager = r.resolve(ASFirebaseStorageProtocol.self)
            let networkManager = r.resolve(ASNetworkManagerProtocol.self)
            return HummingResultRepository(
                storageManager: storageManager,
                networkManager: networkManager,
                mainRepository: mainRepository
            )
        }
    }
}
