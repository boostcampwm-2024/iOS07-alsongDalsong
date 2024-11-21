import ASEncoder
import ASEntity
import Foundation
@preconcurrency internal import FirebaseAuth
@preconcurrency internal import FirebaseDatabase

public final class ASFirebaseAuth: ASFirebaseAuthProtocol {
    private let databaseRef = Database.database().reference()

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

    public func getCurrentUserID() -> String {
        Auth.auth().currentUser?.uid ?? ""
    }
}
