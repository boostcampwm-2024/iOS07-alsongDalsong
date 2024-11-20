import ASNetworkKit
import Combine
import Foundation

public final class RoomActionRepository: RoomActionRepositoryProtocol {
    private let firebaseManager: ASFirebaseManager
    private let networkManager: ASNetworkManager
    
    public init(
        firebaseManager: ASFirebaseManager,
        networkManager: ASNetworkManager
    ) {
        self.firebaseManager = firebaseManager
        self.networkManager = networkManager
    }
    
    public func createRoom(nickname: String, avatar: URL) -> Future<String, any Error> {
        Future { promise in
            Task {
                do {
                    let player = try await self.firebaseManager.signInAnonymously(nickname: nickname, avatarURL: avatar)
                    let roomNumber = try await self.sendRequest(
                        endpointPath: .createRoom,
                        requestBody: ["hostID": player.id]
                    )
                    promise(.success(roomNumber))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
    
    public func joinRoom(nickname: String, avatar: URL, roomNumber: String) -> Future<Bool, any Error> {
        Future { promise in
            Task {
                do {
                    let player = try await self.firebaseManager.signInAnonymously(nickname: nickname, avatarURL: avatar)
                    let roomNumber = try await self.sendRequest(
                        endpointPath: .joinRoom,
                        requestBody: ["roomNumber": roomNumber, "userId": player.id]
                    )
                    let isSuccess = roomNumber == roomNumber
                    promise(.success(isSuccess))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
    
    public func leaveRoom() -> Future<Bool, any Error> {
        // TODO: - 미구현
        Future { promise in
            promise(.success(true))
        }
    }
    
    private func sendRequest(endpointPath: FirebaseEndpoint.Path, requestBody: [String: Any]) async throws -> String {
        let endpoint = FirebaseEndpoint(path: endpointPath, method: .post)
            .update(\.headers, with: ["Content-Type": "application/json"])
        let body = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        let data = try await networkManager.sendRequest(to: endpoint, body: body, option: .none)
        let response = try JSONDecoder().decode([String: String].self, from: data)
        
        guard let roomNumber = response["number"] else {
            throw ASNetworkErrors.responseError
        }
        return roomNumber
    }
}
