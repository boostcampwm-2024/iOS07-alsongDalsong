import ASEntity
internal import FirebaseAuth
internal import FirebaseFirestore
internal import FirebaseDatabase
import Foundation

public final class ASFirebaseManager: ASFirebaseAuthProtocol, ASFirebaseDatabaseProtocol {
    private var databaseRef = Database.database().reference()
    private var firestoreRef = Firestore.firestore()
    private var roomListeners: [String: ListenerRegistration] = [:]
    
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
    
    public func addRoomListener(roomNumber: String, completion: @escaping (Result<Room, any Error>) -> Void) {
        let roomRef = firestoreRef.collection("rooms").document(roomNumber)
        
        let listener = roomRef.addSnapshotListener { documentSnapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = documentSnapshot, document.exists, let roomData = document.data() else {
                completion(.failure(ASNetworkErrors.FirebaseListenerError))
                return
            }
            
            do {
                let room = try self.parseRoomData(roomData)
                completion(.success(room))
            } catch {
                completion(.failure(error))
            }
        }
        
        roomListeners[roomNumber] = listener
    }
    
    public func removeRoomListener(roomNumber: String) {
        if let listener = roomListeners[roomNumber] {
            listener.remove()
            roomListeners.removeValue(forKey: roomNumber)
        }
    }
    
    // MARK: Room Entity로 매핑
    private func parseRoomData(_ data: [String: Any]) throws -> Room {
        var room = Room()
        room.number = data["roomNumber"] as? String
        //TODO: ENCODER 필요
        return room
    }
}
