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
        let lobbyVC = LobbyViewController()
        window?.rootViewController = lobbyVC
        window?.makeKeyAndVisible()
    }
}
