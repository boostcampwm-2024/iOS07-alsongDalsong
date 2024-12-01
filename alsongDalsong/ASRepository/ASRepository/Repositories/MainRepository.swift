import ASDecoder
import ASEncoder
import ASEntity
import ASLogKit
import ASNetworkKit
import ASRepositoryProtocol
import Combine
import Foundation

public final class MainRepository: MainRepositoryProtocol {
    public var myId: String? { ASFirebaseAuth.myID }
    public var room = CurrentValueSubject<Room?, Never>(nil)

    private let databaseManager: ASFirebaseDatabaseProtocol
    private let authManager: ASFirebaseAuthProtocol
    private let storageManager: ASFirebaseStorageProtocol
    private let networkManager: ASNetworkManagerProtocol
    private var cancellables: Set<AnyCancellable> = []

    public init(databaseManager: ASFirebaseDatabaseProtocol,
                authManager: ASFirebaseAuthProtocol,
                storageManager: ASFirebaseStorageProtocol,
                networkManager: ASNetworkManagerProtocol)
    {
        self.databaseManager = databaseManager
        self.authManager = authManager
        self.storageManager = storageManager
        self.networkManager = networkManager
    }

    public func connectRoom(roomNumber: String) {
        self.databaseManager.addRoomListener(roomNumber: roomNumber)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                    case let .failure(error):
                        // TODO: - Error Handling
                        Logger.error(error.localizedDescription)
                    case .finished:
                        return
                }
            } receiveValue: { [weak self] room in
                guard let self else { return }
                self.room.send(room)
            }
            .store(in: &self.cancellables)
    }

    public func disconnectRoom() {
        self.room.send(nil)
        self.databaseManager.removeRoomListener()
    }
    
    public func createRoom(nickname: String, avatar: URL) async throws -> String {
        try await self.authManager.signIn(nickname: nickname, avatarURL: avatar)
        let response: [String: String]? = try await self.sendRequest(
            endpointPath: .createRoom,
            requestBody: ["hostID": myId]
        )
        guard let roomNumber = response?["number"] as? String else {
            throw ASNetworkErrors.responseError
        }
        return roomNumber
    }
    
    public func joinRoom(nickname: String, avatar: URL, roomNumber: String) async throws -> Bool {
        let response: [String: String] = try await self.sendRequest(
            endpointPath: .joinRoom,
            requestBody: ["roomNumber": roomNumber, "userId": myId]
        )
        guard let roomNumberResponse = response["number"] else {
            throw ASNetworkErrors.responseError
        }
        return roomNumberResponse == roomNumber
    }
    
    public func leaveRoom() async throws -> Bool {
        self.disconnectRoom()
        try await self.authManager.signOut()
        return true
    }
    
    public func startGame() async throws -> Bool {
        let response: [String: Bool] = try await self.sendRequest(
            endpointPath: .gameStart,
            requestBody: ["roomNumber": self.room.value?.number, "userId": self.myId]
        )
        guard let response = response["success"] else {
            throw ASNetworkErrors.responseError
        }
        return response
    }
    
    public func changeMode(mode: ASEntity.Mode) async throws -> Bool {
        let response: [String: Bool] = try await self.sendRequest(
            endpointPath: .changeMode,
            requestBody: ["roomNumber": self.room.value?.number, "userId": self.myId, "mode": mode.rawValue]
        )
        guard let isSuccess = response["success"] else {
            throw ASNetworkErrors.responseError
        }
        return isSuccess
    }
    
    public func changeRecordOrder() async throws -> Bool {
        let response: [String: Bool] = try await self.sendRequest(
            endpointPath: .changeRecordOrder,
            requestBody: ["roomNumber": self.room.value?.number, "userId": self.myId]
        )
        guard let isSuccess = response["success"] else {
            throw ASNetworkErrors.responseError
        }
        return isSuccess
    }
    
    public func resetGame() async throws -> Bool {
        let queryItems = [URLQueryItem(name: "userId", value: myId),
                          URLQueryItem(name: "roomNumber", value: self.room.value?.number)]
        let endPoint = FirebaseEndpoint(path: .resetGame, method: .post)
            .update(\.queryItems, with: queryItems)

        let response = try await networkManager.sendRequest(
            to: endPoint,
            type: .none,
            body: nil,
            option: .none
        )
        
        let responseDict = try ASDecoder.decode([String: Bool].self, from: response)
        guard let success = responseDict["success"] else { return false }
        return success
    }

    public func submitMusic(answer: ASEntity.Music) async throws -> Bool {
        let queryItems = [URLQueryItem(name: "userId", value: myId),
                          URLQueryItem(name: "roomNumber", value: self.room.value?.number)]
        let endPoint = FirebaseEndpoint(path: .submitMusic, method: .post)
            .update(\.queryItems, with: queryItems)

        let body = try ASEncoder.encode(answer)
        let response = try await networkManager.sendRequest(to: endPoint, type: .json, body: body, option: .none)
        let responseDict = try ASDecoder.decode([String: String].self, from: response)
        return !responseDict.isEmpty
    }
    
    public func getAvatarUrls() async throws -> [URL] {
        try await self.storageManager.getAvatarUrls()
    }
    
    public func getResource(url: URL) async throws -> Data {
        do {
            guard let endpoint = ResourceEndpoint(url: url) else { throw ASNetworkErrors.urlError }
            let data = try await self.networkManager.sendRequest(to: endpoint, type: .none, body: nil, option: .both)
            return data
        } catch {
            throw error
        }
    }
    
    public func submitAnswer(answer: ASEntity.Music) async throws -> Bool {
        let queryItems = [URLQueryItem(name: "userId", value: myId),
                          URLQueryItem(name: "roomNumber", value: self.room.value?.number)]
        let endPoint = FirebaseEndpoint(path: .submitAnswer, method: .post)
            .update(\.queryItems, with: queryItems)
            .update(\.headers, with: ["Content-Type": "application/json"])

        let body = try ASEncoder.encode(answer)
        let response = try await networkManager.sendRequest(to: endPoint, type: .json, body: body, option: .none)
        let responseDict = try ASDecoder.decode([String: String].self, from: response)
        return !responseDict.isEmpty
    }
    
    public func postRecording(_ record: Data) async throws -> Bool {
        let queryItems = [URLQueryItem(name: "userId", value: myId),
                          URLQueryItem(name: "roomNumber", value: self.room.value?.number)]
        let endPoint = FirebaseEndpoint(path: .uploadRecording, method: .post)
            .update(\.queryItems, with: queryItems)

        let response = try await networkManager.sendRequest(
            to: endPoint,
            type: .multipart,
            body: record,
            option: .none
        )
        let responseDict = try ASDecoder.decode([String: Bool].self, from: response)
        guard let success = responseDict["success"] else { return false }
        return success
    }
    
    private func sendRequest<T: Decodable>(endpointPath: FirebaseEndpoint.Path, requestBody: [String: Any]) async throws -> T {
        let endpoint = FirebaseEndpoint(path: endpointPath, method: .post)
        Logger.debug("Request to \(endpoint)")
        let body = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        let data = try await networkManager.sendRequest(to: endpoint, type: .json, body: body, option: .none)
        let response = try JSONDecoder().decode(T.self, from: data)
        return response
    }
}
