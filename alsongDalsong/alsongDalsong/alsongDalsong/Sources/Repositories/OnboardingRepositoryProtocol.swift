import Foundation

public protocol OnboardingRepositoryProtocol: Sendable {
    func createRoom(nickname: String, avatar: URL?) async throws -> String
    
    func joinRoom(nickname: String, avatar: URL?, roomNumber: String) async throws -> String
    
    func getAvatarUrls() async throws -> [URL]?
    func getAvatarData(url: URL) async throws -> Data?
}
