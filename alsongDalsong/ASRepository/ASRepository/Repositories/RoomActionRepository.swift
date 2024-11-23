import ASEntity
import ASNetworkKit
import Combine
import Foundation

public final class RoomActionRepository: RoomActionRepositoryProtocol {
    private let mainRepository: MainRepositoryProtocol
    private let authManager: ASFirebaseAuthProtocol
    private let networkManager: ASNetworkManagerProtocol
    
    public init(
        mainRepository: MainRepositoryProtocol,
        authManager: ASFirebaseAuthProtocol,
        networkManager: ASNetworkManagerProtocol
    ) {
        self.mainRepository = mainRepository
        self.authManager = authManager
        self.networkManager = networkManager
    }
    
    public func createRoom(nickname: String, avatar: URL) -> Future<String, any Error> {
        Future { promise in
            Task { [weak self] in
                do {
                    let player = try await self?.authManager.signInAnonymously(nickname: nickname, avatarURL: avatar)
                    let response: [String: String]? = try await self?.sendRequest(
                        endpointPath: .createRoom,
                        requestBody: ["hostID": player?.id]
                    )
                    guard let roomNumber = response?["number"] as? String else {
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
            Task { [weak self] in
                do {
                    let player = try await self?.authManager.signInAnonymously(nickname: nickname, avatarURL: avatar)
                    let response: [String: String]? = try await self?.sendRequest(
                        endpointPath: .joinRoom,
                        requestBody: ["roomNumber": roomNumber, "userId": player?.id]
                    )
                    guard let roomNumberResponse = response?["number"] as? String else {
                        throw ASNetworkErrors.responseError
                    }
                    roomNumberResponse == roomNumber ? promise(.success(true)) : promise(.success(false))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
    
    public func leaveRoom() -> Future<Bool, any Error> {
        Future { promise in
            Task { [weak self] in
                do {
                    self?.mainRepository.disconnecRoom()
                    try await self?.authManager.signOut()
                    promise(.success(true))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
    
    public func startGame(roomNumber: String) -> Future<Bool, any Error> {
        Future { promise in
            Task { [weak self] in
                do {
                    let id = self?.authManager.getCurrentUserID()
                    let response: [String: Bool]? = try await self?.sendRequest(
                        endpointPath: .gameStart,
                        requestBody: ["roomNumber": roomNumber, "userId": id]
                    )
                    guard let response = response?["success"] as? Bool else {
                        promise(.failure(ASNetworkErrors.responseError))
                        return
                    }
                    promise(.success(response))
                }
            }
        }
    }
    
    public func changeMode(roomNumber: String, mode: Mode) async throws -> Bool {
        do {
            let id = self.authManager.getCurrentUserID()
            let response: [String: Bool] = try await self.sendRequest(
                endpointPath: .changeMode,
                requestBody: ["roomNumber": roomNumber, "userId": id, "mode": mode.rawValue]
            )
            guard let isSuccess = response["success"] as? Bool else {
                throw ASNetworkErrors.responseError
            }
            return isSuccess
        } catch {
            throw error
        }
    }
    
    private func sendRequest<T: Decodable>(endpointPath: FirebaseEndpoint.Path, requestBody: [String: Any]) async throws -> T {
        let endpoint = FirebaseEndpoint(path: endpointPath, method: .post)
            .update(\.headers, with: ["Content-Type": "application/json"])
        let body = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        let data = try await networkManager.sendRequest(to: endpoint, body: body, option: .none)
        let response = try JSONDecoder().decode(T.self, from: data)
        return response
    }
}
