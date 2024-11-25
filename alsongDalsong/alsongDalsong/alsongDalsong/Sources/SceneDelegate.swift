import ASContainer
import ASNetworkKit
import ASRepository
import ASCacheKit
import Firebase
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene,
               willConnectTo _: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions)
    {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        FirebaseApp.configure()
        ASFirebaseAuth.configure()
        assembleDependencies()
        var inviteCode = ""
        
        if let url = connectionOptions.urlContexts.first?.url {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            if let roomNumber = components?.queryItems?.first(where: { item in
                item.name == "roomnumber"
            })?.value {
                inviteCode = roomNumber
            }
        }
        window = UIWindow(windowScene: windowScene)
        
        let onboardingVM = OnboardingViewModel(
            avatarRepository: DIContainer.shared.resolve(AvatarRepositoryProtocol.self),
            roomActionRepository: DIContainer.shared.resolve(RoomActionRepositoryProtocol.self)
        )
        let onboardingVC = OnboardingViewController(viewmodel: onboardingVM, inviteCode: inviteCode)
        let navigationController = UINavigationController(rootViewController: onboardingVC)
        navigationController.navigationBar.isHidden = true
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    private func assembleDependencies() {
        DIContainer.shared.addAssemblies([CacheAssembly(), NetworkAssembly(), RepsotioryAssembly()])
    }
}
