import ASEntity
import Foundation

public protocol ASFirebaseAuthProtocol: Sendable {
    func signInAnonymously(nickname: String, avatarURL: URL?) async throws -> Player
    func signOut() async throws
}
