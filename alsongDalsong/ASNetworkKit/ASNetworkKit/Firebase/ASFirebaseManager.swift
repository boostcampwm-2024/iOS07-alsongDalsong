import ASEntity
internal import FirebaseAuth
internal import FirebaseDatabase
import Foundation

public final class ASFirebaseManager: ASFirebaseAuthProtocol, ASFirebaseDatabaseProtocol {
    private var databaseRef = Database.database().reference()
    private var roomListeners: [String: DatabaseHandle] = [:]
    
    public init() {}
    
    public func signInAnonymously(nickName: String, avatarURL: URL?) async throws -> Player {
        guard let authResult = try? await Auth.auth().signInAnonymously() else {
            throw ASNetworkErrors.FirebaseSignInError
        }
       
        let playerID = authResult.user.uid
        let playerData: [String: Any] = [
            "id": authResult.user.uid,
            "avatar": avatarURL?.absoluteString ?? "",
            "nickname": nickName,
            "score": 0,
            "order": 0
        ]
        
        do {
            try await databaseRef
                .child("players")
                .child(playerID)
                .setValue(playerData)
        } catch {
            throw ASNetworkErrors.FirebaseSignInError
        }
        
        return Player(
            id: playerID,
            avatarUrl: avatarURL,
            nickname: nickName,
            score: 0,
            order: 0
        )
    }
    
    public func signOut() async throws {
        guard let userID = Auth.auth().currentUser?.uid else {
            throw ASNetworkErrors.FirebaseSignOutError
        }
        do {
            try await databaseRef.child("players").child(userID).removeValue()
            try Auth.auth().signOut()
        } catch {
            throw ASNetworkErrors.FirebaseSignOutError
        }
    }
    
    public func addRoomListener(roomId: String, completion: @escaping (Result<Room, any Error>) -> Void) {}
    
    public func removeRoomListener(roomId: String) {}
}
