import Firebase
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene,
               willConnectTo _: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        FirebaseApp.configure()
        
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
        let onboardingVC = OnboardingViewController(inviteCode: inviteCode)
        let navigationController = UINavigationController(rootViewController: onboardingVC)
        navigationController.navigationBar.isHidden = true
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
//    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
//        guard let url = URLContexts.first?.url else { return }
//        
//        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
//        
//        if let roomNumber = components?.queryItems?.first(where: { item in
//            item.name == "roomNumber"
//        })?.value {
//            guard let windowScene = (scene as? UIWindowScene) else { return }
//            window = UIWindow(windowScene: windowScene)
//            let onboardingVC = OnboardingViewController()
//            let navigationController = UINavigationController(rootViewController: onboardingVC)
//            navigationController.navigationBar.isHidden = true
//            window?.rootViewController = navigationController
//            window?.makeKeyAndVisible()
//        }
//    }
    
}
