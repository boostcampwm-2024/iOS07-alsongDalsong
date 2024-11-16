import ASEntity
import Foundation

public protocol ASFirebaseAuthProtocol {
    func signInAnonymously(nickname: String, avatarURL: URL?) async throws -> Player
    func signOut() async throws
}
