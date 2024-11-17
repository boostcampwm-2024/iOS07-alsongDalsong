import Foundation

public protocol OnboardingRepositoryProtocol {
    func createRoom(nickname: String, avatar: URL) async -> Bool
    
    func joinRoom(nickname:String, avatar: URL?, roomNumber: String, completion: @escaping @Sendable (Bool) -> Void)
    
    

}

public enum RoomResponse: Sendable {
    case success
    case failed
}
