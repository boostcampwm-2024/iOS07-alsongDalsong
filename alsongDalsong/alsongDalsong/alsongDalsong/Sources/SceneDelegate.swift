import Firebase
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo _: UISceneSession,
               options _: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        FirebaseApp.configure()
        window = UIWindow(windowScene: windowScene)
        let onboardingVC = OnboardingViewController()
        let navigationController = UINavigationController(rootViewController: onboardingVC)
        navigationController.navigationBar.isHidden = true
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}
