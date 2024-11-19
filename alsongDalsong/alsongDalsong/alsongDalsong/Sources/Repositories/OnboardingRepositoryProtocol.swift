import Foundation

public protocol OnboardingRepositoryProtocol: Sendable {
    func createRoom(nickname: String, avatar: URL?) async throws -> String
    
    func joinRoom(nickname: String, avatar: URL?, roomNumber: String) async throws -> String
}
