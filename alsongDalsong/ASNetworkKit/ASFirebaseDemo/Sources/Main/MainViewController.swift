import ASNetworkKit
import ASEntity
import UIKit

final class MainViewController: UIViewController {
    var nicknameField: UITextField!
    var textField: UITextField!
    var createButton: UIButton!
    var joinButton: UIButton!
    
    let firebaseManager = ASFirebaseManager()
    let networkManger = ASNetworkManager()
    var player: Player!
    
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        setupUI()
        setupLayout()
    }
    
    private func setupUI() {
        nicknameField = UITextField()
        nicknameField.borderStyle = .roundedRect
        nicknameField.placeholder = "닉네임 입력해주세요"
        
        textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "방번호 입력해주세요"
        
        createButton = UIButton()
        createButton.setTitle("방 생성하기", for: .normal)
        createButton.setTitleColor(.blue, for: .normal)
        createButton.setTitleColor(.gray, for: .disabled)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        
        joinButton = UIButton()
        joinButton.setTitle("방 참가하기", for: .normal)
        joinButton.setTitleColor(.blue, for: .normal)
        joinButton.setTitleColor(.gray, for: .disabled)
        joinButton.addTarget(self, action: #selector(joinButtonTapped), for: .touchUpInside)
    }
    
    private func setupLayout() {
        [nicknameField, textField, createButton, joinButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            nicknameField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nicknameField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -150),
            
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            
            createButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            
            joinButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            joinButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50)
        ])
    }
    
    @objc private func createButtonTapped() {
        Task {
            do {
                createButton.isEnabled = false
                joinButton.isEnabled = false
                try await connectToFirebase()
                
                let endpoint = FirebaseEndpoint(path: .createRoom, method: .post)
                    .update(\.headers, with: ["Content-Type": "application/json"])
                let bodyData = ["hostID": player.id]
                let body = try JSONSerialization.data(withJSONObject: bodyData, options: [])
                let data = try await networkManger.sendRequest(to: endpoint, body: body)
                let response = try JSONDecoder().decode([String: String].self, from: data)
                
                if let roomNumber = response["roomNumber"] {
                    try await join(roomNumber: roomNumber)
                    navigateToLobby(roomNumber: roomNumber)
                }
            } catch(let error) {
                createButton.isEnabled = true
                joinButton.isEnabled = true
                print("error: \(error)")
            }
        }
    }
    
    @objc private func joinButtonTapped() {
        Task {
            do {
                createButton.isEnabled = false
                joinButton.isEnabled = false
                try await connectToFirebase()
                
                let endpoint = FirebaseEndpoint(path: .joinRoom, method: .post)
                    .update(\.headers, with: ["Content-Type": "application/json"])
                let bodyData = ["roomNumber": textField.text!, "userId": player.id]
                let body = try JSONSerialization.data(withJSONObject: bodyData, options: [])
                let room = try await networkManger.sendRequest(to: endpoint, body: body)
                if let jsonObject = try JSONSerialization.jsonObject(with: room, options: []) as? [String: Any],
                   let roomNumber = jsonObject["number"] as? String {
                    navigateToLobby(roomNumber: roomNumber)
                }
            } catch {
                createButton.isEnabled = true
                joinButton.isEnabled = true
                print("error: \(error)")
            }
        }
    }
    
    private func join(roomNumber: String) async throws {
        let endpoint = FirebaseEndpoint(path: .joinRoom, method: .post)
            .update(\.headers, with: ["Content-Type": "application/json"])
        let bodyData = ["roomNumber": roomNumber, "userId": player.id]
        let body = try JSONSerialization.data(withJSONObject: bodyData, options: [])
        try await networkManger.sendRequest(to: endpoint, body: body)
    }
    
    private func connectToFirebase() async throws {
        player = try await firebaseManager.signInAnonymously(
            nickname: nicknameField.text!,
            avatarURL: nil
        )
    }
    
    private func navigateToLobby(roomNumber: String) {
        let lobbyVC = LobbyViewController(roomNumber: roomNumber)
        navigationController?.pushViewController(lobbyVC, animated: true)
    }
}

