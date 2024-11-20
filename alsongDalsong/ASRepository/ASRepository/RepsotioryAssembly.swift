import ASContainer
import ASNetworkKit

public final class RepsotioryAssembly: Assembly {
    
    public func assemble(container: Registerable) {
        container.register(MainRepositoryProtocol.self) { r in
            let firebaseManager = r.resolve(ASFirebaseDatabaseProtocol.self)
            return MainRepository(
                firebaseManager: firebaseManager
            )
        }
        
        container.register(AnswersRepositoryProtocol.self) { r in
            let mainRepository = r.resolve(MainRepository.self)
            return AnswersRepository(
                mainRepository: mainRepository
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
            let mainRepository = r.resolve(MainRepository.self)
            return GameStatusRepository(
                mainRepository: mainRepository
            )
        }
        
        container.register(PlayersRepositoryProtocol.self) { r in
            let mainRepository = r.resolve(MainRepository.self)
            return PlayersRepository(
                mainRepository: mainRepository
            )
        }
        
        container.register(RecordsRepositoryProtocol.self) { r in
            let mainRepository = r.resolve(MainRepository.self)
            return RecordsRepository(
                mainRepository: mainRepository
            )
        }
        
        container.register(RoomActionRepositoryProtocol.self) { r in
            let authManager = r.resolve(ASFirebaseAuthProtocol.self)
            let networkManager = r.resolve(ASNetworkManagerProtocol.self)
            return RoomActionRepository(
                authManager: authManager,
                networkManager: networkManager
            )
        }
        
        container.register(RoomInfoRepositoryProtocol.self) { r in
            let mainRepository = r.resolve(MainRepository.self)
            return RoomInfoRepository(
                mainRepository: mainRepository
            )
        }
        
        container.register(SelectedRecordsRepositoryProtocol.self) { r in
            let mainRepository = r.resolve(MainRepository.self)
            return SelectedRecordsRepository(
                mainRepository: mainRepository
            )
        }
        
        container.register(SubmitsRepositoryProtocol.self) { r in
            let mainRepository = r.resolve(MainRepository.self)
            return SubmitsRepository(
                mainRepository: mainRepository
            )
        }
    }
}
