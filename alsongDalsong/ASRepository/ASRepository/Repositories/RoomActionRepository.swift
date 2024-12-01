import ASEntity
import ASRepositoryProtocol
import Combine
import Foundation

public final class RoomActionRepository: RoomActionRepositoryProtocol {
    private let mainRepository: MainRepositoryProtocol
    
    public init(
        mainRepository: MainRepositoryProtocol
    ) {
        self.mainRepository = mainRepository
    }

    public func createRoom(nickname: String, avatar: URL) async throws -> String {
        try await mainRepository.createRoom(nickname: nickname, avatar: avatar)
    }
    
    public func joinRoom(nickname: String, avatar: URL, roomNumber: String) async throws -> Bool {
        try await mainRepository.joinRoom(nickname: nickname, avatar: avatar, roomNumber: roomNumber)
    }
    
    public func leaveRoom() async throws -> Bool {
        try await mainRepository.leaveRoom()
    }
    
    public func startGame() async throws -> Bool {
        try await mainRepository.startGame()
    }
    
    public func changeMode(mode: Mode) async throws -> Bool {
        try await mainRepository.changeMode(mode: mode)
    }
    
    public func changeRecordOrder() async throws -> Bool {
        try await mainRepository.changeRecordOrder()
    }
    
    public func resetGame() async throws -> Bool {
        try await mainRepository.resetGame()
    }
}
