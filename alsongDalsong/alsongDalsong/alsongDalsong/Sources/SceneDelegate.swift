import ASCacheKit
import ASContainer
import ASLogKit
import ASNetworkKit
import ASRepository
import ASRepositoryProtocol
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
            roomActionRepository: DIContainer.shared.resolve(RoomActionRepositoryProtocol.self),
            dataDownloadRepository: DIContainer.shared.resolve(DataDownloadRepositoryProtocol.self)
        )
        let onboardingVC = OnboardingViewController(viewmodel: onboardingVM, inviteCode: inviteCode)
        let navigationController = UINavigationController(rootViewController: onboardingVC)
        navigationController.navigationBar.isHidden = true
        navigationController.interactivePopGestureRecognizer?.isEnabled = false
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_: UIScene) {
        let firebaseManager = DIContainer.shared.resolve(ASFirebaseAuthProtocol.self)
        Task {
            do {
                try await firebaseManager.signOut()
            } catch {
                Logger.error(error.localizedDescription)
            }
        }
    }
    
    private func assembleDependencies() {
        DIContainer.shared.addAssemblies([CacheAssembly(), NetworkAssembly(), RepsotioryAssembly()])
    }
}
