import ASEntity
import ASDecoder
import ASEncoder
import Combine
internal import FirebaseAuth
internal import FirebaseFirestore
internal import FirebaseDatabase
import Foundation

public final class ASFirebaseManager: ASFirebaseAuthProtocol, ASFirebaseDatabaseProtocol {
    private var databaseRef = Database.database().reference()
    private var firestoreRef = Firestore.firestore()
    private var roomListeners: ListenerRegistration?
    
    private var roomPublisher = PassthroughSubject<Room, Error>()
    
    public init() {}
    
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
    
    public func getCurrentUserID() -> String {
        return Auth.auth().currentUser?.uid ?? ""
    }
    
    public func addRoomListener(roomNumber: String) -> AnyPublisher<Room, Error> {
        let roomRef = firestoreRef.collection("rooms").document(roomNumber)
        let listener = roomRef.addSnapshotListener { documentSnapshot, error in
            if let error = error {
                return
            }
            
            guard let document = documentSnapshot, document.exists, let roomData = document.data() else {
                
                return self.roomPublisher.send(completion: .failure(ASNetworkErrors.FirebaseListenerError))
            }
            
            do {
                let room = try self.parseRoomData(roomData)
                return self.roomPublisher.send(room)
            } catch {
                return self.roomPublisher.send(completion: .failure(ASNetworkErrors.FirebaseListenerError))
            }
        }
        
        roomListeners = listener
    }
    
    public func removeRoomListener(roomNumber: String) {
        roomListeners?.remove()
    }
    
    // TODO: Room Entity로 매핑 (ASDecoder에 Dictionary를 한번에 Entitiy로 Decoding 하는 기능이 필요할듯 합니다.)
    private func parseRoomData(_ data: [String: Any]) throws -> Room {
        var room = Room()
        
        room.number = data["number"] as? String
        
        if let hostData = data["host"] as? [String: Any] {
            let hostJSONData = try JSONSerialization.data(withJSONObject: hostData)
            room.host = try ASDecoder.decode(Player.self, from: hostJSONData)
        }
        
        if let playersData = data["players"] as? [[String: Any]] {
            let playersJSONData = try JSONSerialization.data(withJSONObject: playersData)
            room.players = try ASDecoder.decode([Player].self, from: playersJSONData)
        }
        
        if let mode = data["mode"] as? String {
            room.mode = Mode(rawValue: mode)
        }
        
        if let status = data["status"] as? String {
            room.status = Status(rawValue: status)
        }
        
        room.round = data["round"] as? UInt8
        
        // TODO: Decoding 에러 발생, 미해결
        if let recordsData = data["records"] as? [[String: Any]] {
            let recordsJSONData = try JSONSerialization.data(withJSONObject: recordsData)
            room.records = try ASDecoder.decode([[Record]].self, from: recordsJSONData)
        }
        
        if let answersData = data["answers"] as? [[String: Any]] {
            let answersJSONData = try JSONSerialization.data(withJSONObject: answersData)
            room.answers = try ASDecoder.decode([Answer].self, from: answersJSONData)
        }
        
        if let dueTime = data["dueTime"] as? Timestamp {
            room.dueTime = dueTime.dateValue()
        }
        
        room.selectedRecords = data["selectedRecords"] as? [UInt8]
        
        if let submitsData = data["submits"] as? [[String: Any]] {
            let submitsJSONData = try JSONSerialization.data(withJSONObject: submitsData)
            room.submits = try ASDecoder.decode([Answer].self, from: submitsJSONData)
        }
        print(room)
        return room
    }
}
