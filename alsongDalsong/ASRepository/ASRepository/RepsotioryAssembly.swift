import ASContainer
import ASNetworkKit

final class RepsotioryAssembly: Assembly {
    func assemble(container: DIContainer) {
        container.register(MainRepository.self) {
            let firebaseManager = container.resolve(ASFirebaseDatabaseProtocol.self)
            return MainRepository(firebaseManager: firebaseManager)
        }
        
        container.register(AnswersRepositoryProtocol.self) {
            AnswersRepository(mainRepository: container.resolve(MainRepository.self))
        }
        
        container.register(AvatarRepositoryProtocol.self) {
            let firebaseManager = container.resolve(ASFirebaseStorageProtocol.self)
            let networkManager = container.resolve(ASNetworkManagerProtocol.self)
            return AvatarRepository(firebaseManager: firebaseManager, networkManager: networkManager)
        }
    }
}
