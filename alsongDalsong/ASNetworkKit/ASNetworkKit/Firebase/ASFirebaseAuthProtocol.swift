import ASEntity

public protocol ASFirebaseAuthProtocol {
    func signInAnonymously() async throws -> Player
    func signOut() async throws
}
