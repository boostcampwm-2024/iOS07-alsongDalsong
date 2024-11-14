import ASEntity

public final class ASFirebaseManager: ASFirebaseAuthProtocol, ASFirebaseDatabaseProtocol {
    
    public init() {}
    
    public func signInAnonymously() async throws -> Player {
        return Player()
    }
    
    public func signOut() async throws {}
    
    public func addRoomListener(roomId: String, completion: @escaping (Result<Room, any Error>) -> Void) {}
    
    public func removeRoomListener(roomId: String) {}
}
