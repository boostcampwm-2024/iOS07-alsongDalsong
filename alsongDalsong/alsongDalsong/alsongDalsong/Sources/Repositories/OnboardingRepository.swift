import Foundation
import ASNetworkKit
import ASEntity
import ASCacheKit

final class OnboardingRepository: OnboardingRepositoryProtocol {
    let firebaseManager: ASFirebaseManager
    let networkManager: ASNetworkManager
    
    init (
        firebaseManager: ASFirebaseManager,
        networkManager: ASNetworkManager
    ) {
        self.firebaseManager = firebaseManager
        self.networkManager = networkManager
    }
    
    func createRoom(nickname: String, avatar: URL?) async throws -> String {
        do {
            let player = try await firebaseManager.signInAnonymously(nickname: nickname, avatarURL: avatar)
            let endpoint = FirebaseEndpoint(path: .createRoom, method: .post)
                .update(\.headers, with: ["Content-Type": "application/json"])
            let bodyData = ["hostID": player.id]
            let body = try JSONSerialization.data(withJSONObject: bodyData, options: [])
            let data = try await networkManager.sendRequest(to: endpoint, body: body, option: .none)
            let response = try JSONDecoder().decode([String: String].self, from: data)
            guard let roomNumber = response["roomNumber"] else {
                throw ASNetworkErrors.responseError
            }
            return roomNumber
            
        } catch {
            throw error
        }
    }
    
    func joinRoom(nickname: String, avatar: URL?, roomNumber: String) async throws -> String {
        do {
            let player = try await firebaseManager.signInAnonymously(
                nickname: nickname,
                avatarURL: avatar
                )
            let endpoint = FirebaseEndpoint(path: .joinRoom, method: .post)
                .update(\.headers, with: ["Content-Type": "application/json"])
            let bodyData = ["roomNumber": roomNumber, "userId": player.id]
            let body = try JSONSerialization.data(withJSONObject: bodyData, options: [])
            let room = try await networkManager.sendRequest(to: endpoint, body: body, option: .none)
            if let jsonObject = try JSONSerialization.jsonObject(with: room, options: []) as? [String: Any],
               let roomNumber = jsonObject["number"] as? String {
                return roomNumber
            }
        } catch let error {
            throw error
        }
        return ""
    }
    
    func getAvatarUrls() async throws -> [URL]? {
        do {
            return try await firebaseManager.getAvatarUrls()
        }
        catch {
            throw error
        }
    }
    
    func getAvatarData(url: URL) async throws -> Data? {
        do {
            guard let endpoint = ImageEndpoint(url: url) else { return nil }
            return try await self.networkManager.sendRequest(to: endpoint)
        }
        catch {
            throw error
        }
    }
}
