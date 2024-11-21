import ASNetworkKit
import Combine
import Foundation

public final class RoomActionRepository: RoomActionRepositoryProtocol {
    private let authManager: ASFirebaseAuthProtocol
    private let networkManager: ASNetworkManagerProtocol
    
    public init(
        authManager: ASFirebaseAuthProtocol,
        networkManager: ASNetworkManagerProtocol
    ) {
        self.authManager = authManager
        self.networkManager = networkManager
    }
    
    public func createRoom(nickname: String, avatar: URL) -> Future<String, any Error> {
        Future { promise in
            Task {
                do {
                    let player = try await self.authManager.signInAnonymously(nickname: nickname, avatarURL: avatar)
                    let response = try await self.sendRequest(
                        endpointPath: .createRoom,
                        requestBody: ["hostID": player.id]
                    )
                    guard let roomNumber = response["number"] else {
                        throw ASNetworkErrors.responseError
                    }
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
                    let player = try await self.authManager.signInAnonymously(nickname: nickname, avatarURL: avatar)
                    let response = try await self.sendRequest(
                        endpointPath: .joinRoom,
                        requestBody: ["roomNumber": roomNumber, "userId": player.id]
                    )
                    let responseRoomNumber = response["number"]
                    responseRoomNumber == roomNumber ? promise(.success(true)) : promise(.success(false))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
    
    public func leaveRoom() -> Future<Bool, any Error> {
        Future { promise in
            Task {
                do {
                    try await self.authManager.signOut()
                    promise(.success(true))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
    
    public func startGame(roomNumber: String) -> Future<Bool, any Error> {
        Future { promise in
            Task {
                do {
                    let id = self.authManager.getCurrentUserID()
                    let response = try await self.sendRequest(
                        endpointPath: .gameStart,
                        requestBody: ["roomNumber": roomNumber, "userId": id]
                    )
                    let status = response["status"]
                    response["status"] == "success" ? promise(.success(true)) : promise(.success(false))
                }
            }
        }
    }
    
    private func sendRequest(endpointPath: FirebaseEndpoint.Path, requestBody: [String: Any]) async throws -> [String: String] {
        let endpoint = FirebaseEndpoint(path: endpointPath, method: .post)
            .update(\.headers, with: ["Content-Type": "application/json"])
        let body = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        let data = try await networkManager.sendRequest(to: endpoint, body: body, option: .none)
        let response = try JSONDecoder().decode([String: String].self, from: data)
        return response
        
    }
}
