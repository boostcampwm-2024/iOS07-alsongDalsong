import ASNetworkKit
import ASEntity

final class LobbyRepository {
    let firebaseManager: ASFirebaseDatabaseProtocol & ASFirebaseAuthProtocol = ASFirebaseManager()
    
    func observeLobby(roomNumber: String, completion: @escaping (LobbyData) -> Void) {
        firebaseManager.addRoomListener(roomNumber: roomNumber) { [weak self] result in
            switch result {
                case .success(let room):
                let lobbyData = LobbyData(
                    roomNumber: room.number ?? "",
                    players: room.players ?? [] ,
                    mode: room.mode ?? .harmony ,
                    isHost: self?.firebaseManager.getCurrentUserID() == room.host?.id
                )
                completion(lobbyData)
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    func gameStart() {
        
    }
    
    func exitLobby() {
        
    }
}
