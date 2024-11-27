import ASEntity
import ASNetworkKit
import Combine
import Foundation

final class LobbyViewModel {
    @Published var room: Room? = nil
    @Published var startState: Bool = false
    
    public var isHost: Bool {
        guard let hostID = room?.host?.id else { return false }
        return hostID == firebaseManager.getCurrentUserID()
    }
    
    private var roomNumber: String
    
    private let firebaseManager: ASFirebaseManager
    private let networkManager: ASNetworkManager
    
    enum Input {
        case viewDidLoad
        case startGame
        case viewDidDisappear
    }
    
    init(roomNumber: String) {
        self.roomNumber = roomNumber
        self.firebaseManager = ASFirebaseManager()
        self.networkManager = ASNetworkManager()
    }
    
    func action(_ input: Input) {
        switch input {
            case .viewDidLoad:
                addRoomListener(roomNumber: roomNumber)
            case .startGame:
                startGame()
            case .viewDidDisappear:
                removeRoomListener()
        }
    }
    
    func addRoomListener(roomNumber: String) {
        firebaseManager.addRoomListener(roomNumber: roomNumber) { [weak self] result in
            switch result {
                case .success(let room):
                    self?.room = room
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    func removeRoomListener() {
        if let roomNumber = room?.number {
            firebaseManager.removeRoomListener(roomNumber: roomNumber)
        }
    }
    
    func startGame() {
        startState = true
        guard let roomNumber = room?.number else { startState = false; return }
        // 데모 앱에선 간단하게 뷰 모델에서 네트워크 요청 보내는 것으로 대체
        Task {
            do {
                let endpoint = FirebaseEndpoint(path: .gameStart, method: .post)
                let bodyData = ["roomNumber": roomNumber,
                                "userId": firebaseManager.getCurrentUserID()]
                let body = try JSONSerialization.data(withJSONObject: bodyData, options: [])
                let data = try await networkManager.sendRequest(to: endpoint, body: body)
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
                startState = jsonObject?["status"] == "success"
            } catch {
                startState = true
                print(error)
            }
        }
    }
}
