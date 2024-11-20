import ASEntity
import ASDecoder
import ASEncoder
import Combine
internal import FirebaseAuth
@preconcurrency internal import FirebaseFirestore
@preconcurrency internal import FirebaseDatabase
@preconcurrency internal import FirebaseStorage
import Foundation

public final class ASFirebaseManager: Sendable {
    private let databaseRef = Database.database().reference()
    private let firestoreRef = Firestore.firestore()
    private var roomListeners: ListenerRegistration?
    private let storageRef = Storage.storage().reference()
    
    private var roomPublisher = PassthroughSubject<Room, Error>()
    
    public init() {}
    
    public func getCurrentUserID() -> String {
        return Auth.auth().currentUser?.uid ?? ""
    }
    
    public func getAvatarUrls() async throws -> [URL] {
        let avatarRef = storageRef.child("avatar")
        do {
            let result = try await avatarRef.listAll()
            return try await fetchDownloadURLs(from: result.items)
        } catch {
            throw ASNetworkErrors.responseError
        }
    }
    
    // 다운로드 URL 가져오기
    private func fetchDownloadURLs(from items: [StorageReference]) async throws -> [URL] {
        try await withThrowingTaskGroup(of: URL.self) { taskGroup in
            for item in items {
                taskGroup.addTask {
                    try await self.downloadURL(for: item)
                }
            }
            
            return try await taskGroup.reduce(into: []) { urls, url in
                urls.append(url)
            }
        }
    }

    private func downloadURL(for item: StorageReference) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            item.downloadURL { url, error in
                if let url = url {
                    continuation.resume(returning: url)
                } else if let error = error {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

extension ASFirebaseManager: ASFirebaseAuthProtocol {
    public func signInAnonymously(nickname: String, avatarURL: URL?) async throws -> Player {
        do {
            let authResult = try await Auth.auth().signInAnonymously()
            let playerID = authResult.user.uid
            let player = Player(id: playerID, avatarUrl: avatarURL, nickname: nickname, score: 0, order: 0)
            let playerData = try ASEncoder.encode(player)
            let dict = try JSONSerialization.jsonObject(with: playerData, options: .allowFragments) as? [String: Any]
            let userStatusRef = databaseRef.child("players").child(playerID)
            userStatusRef.keepSynced(true)
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
