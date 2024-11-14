import ASNetworkKit
import UIKit

class MainViewController: UIViewController {
    private var loginButton: UIButton!
    private var logoutButton: UIButton!
    
    let firebaseManager = ASFirebaseManager()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
    }
    
    private func setupUI() {
        loginButton = UIButton()
        loginButton.setTitle("Login", for: .normal)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        logoutButton = UIButton()
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
    }
    
    private func setupLayout() {
        [loginButton, logoutButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50)
        ])
    }
    
    @objc private func loginButtonTapped() {
        Task {
            do {
                let player = try await firebaseManager.signInAnonymously(nickName: "test", avatarURL: nil)
                print("player: \(player)")
            } catch {
                print("error: \(error)")
            }
        }
    }
    
    @objc private func logoutButtonTapped() {
        Task {
            do {
                try await firebaseManager.signOut()
                print("로그아웃 성공!")
            } catch {
                print("error: \(error)")
            }
        }
    }
}
