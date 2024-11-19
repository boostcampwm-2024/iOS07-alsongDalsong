import ASEntity
import ASDecoder
import ASEncoder
import Combine
internal import FirebaseAuth
@preconcurrency internal import FirebaseFirestore
@preconcurrency internal import FirebaseDatabase
import Foundation

public final class ASFirebaseManager: Sendable {
    private let databaseRef = Database.database().reference()
    private let firestoreRef = Firestore.firestore()
    private var roomListeners: ListenerRegistration?
    
    private var roomPublisher = PassthroughSubject<Room, Error>()
    
    public init() {}
    
    public func getCurrentUserID() -> String {
        return Auth.auth().currentUser?.uid ?? ""
    }
}

extension ASFirebaseManager: ASFirebaseAuthProtocol {
    public func signInAnonymously(nickname: String, avatarURL: URL?) async throws -> Player {
        do {
            let authResult = try await Auth.auth().signInAnonymously()
            let playerID = authResult.user.uid
            let player = Player(id: playerID, avatarUrl: avatarURL, nickname: nickname, score: 0, order: 0)
            let playerData = try ASEncoder.encode(player)
            // MARK: setValue 함수가 Data 타입은 안들어가서 AS Encoder에 Dict로 변환하는 게 필요할듯 합니다.
            let dict = try JSONSerialization.jsonObject(with: playerData, options: .allowFragments) as? [String: Any]
            let userStatusRef = databaseRef.child("players").child(playerID)
            let connectedRef = databaseRef.child(".info/connected")
            connectedRef.observe(.value) { snapshot in
                guard let isConnected = snapshot.value as? Bool else { return }
                if isConnected {
                    userStatusRef.setValue(dict)
                    userStatusRef.onDisconnectRemoveValue()
                }
            }
            return player
        } catch {
            throw ASNetworkErrors.FirebaseSignInError
        }
    }
    
    public func signOut() async throws {
        do {
            guard let userID = Auth.auth().currentUser?.uid else { throw ASNetworkErrors.FirebaseSignOutError }
            try await databaseRef.child("players").child(userID).removeValue()
            try Auth.auth().signOut()
        } catch {
            throw ASNetworkErrors.FirebaseSignOutError
        }
    }
}

extension ASFirebaseManager: ASFirebaseDatabaseProtocol {
    public func addRoomListener(roomNumber: String) -> AnyPublisher<Room, Error> {
        let roomRef = firestoreRef.collection("rooms").document(roomNumber)
        let listener = roomRef.addSnapshotListener { documentSnapshot, error in
            if let error = error {
                return
            }
            
            guard let document = documentSnapshot, document.exists else {
                return self.roomPublisher.send(completion: .failure(ASNetworkErrors.FirebaseListenerError))
            }
            
            do {
                let room = try document.data(as: Room.self)
                return self.roomPublisher.send(room)
            } catch {
                return self.roomPublisher.send(completion: .failure(ASNetworkErrors.FirebaseListenerError))
            }
        }
        
        roomListeners = listener
        return roomPublisher.eraseToAnyPublisher()
    }
    
    public func removeRoomListener(roomNumber: String) {
        roomListeners?.remove()
    }
}
