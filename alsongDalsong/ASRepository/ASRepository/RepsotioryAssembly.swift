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
            
            AvatarRepository(firebaseManager: <#T##ASFirebaseManager#>, networkManager: <#T##ASNetworkManager#>)
        }
        
        
    }
}
