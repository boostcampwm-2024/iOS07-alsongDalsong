import Foundation
import ASNetworkKit

final class OnboradingRepository: OnboardingRepositoryProtocol {
    let firebaseManager: ASFirebaseAuthProtocol = ASFirebaseManager()
    let networkManager = ASNetworkManager()
    
    func createRoom(nickname: String, avatar: URL?) async throws -> String {
        do {
            let player = try await firebaseManager.signInAnonymously(nickname: nickname, avatarURL: avatar)
            let endpoint = FirebaseEndpoint(path: .createRoom, method: .post)
                .update(\.headers, with: ["Content-Type": "application/json"])
            let bodyData = ["hostID": player.id]
            let body = try JSONSerialization.data(withJSONObject: bodyData, options: [])
            let data = try await networkManager.sendRequest(to: endpoint, body: body)
            let response = try JSONDecoder().decode([String: String].self, from: data)
            guard let roomNumber = response["roomNumber"] else {
                throw ASNetworkErrors.responseError
            }
            return roomNumber
        } catch {
            throw error
        }
    }
    
    func joinRoom(nickname: String, avatar: URL?, roomNumber: String) async throws -> Bool {
        return true
    }
}
