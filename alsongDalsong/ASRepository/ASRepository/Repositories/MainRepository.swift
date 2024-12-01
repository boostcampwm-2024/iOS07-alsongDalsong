import ASDecoder
import ASEncoder
import ASEntity
import ASLogKit
import ASNetworkKit
import Combine
import Foundation
import ASRepositoryProtocol

public final class MainRepository: MainRepositoryProtocol {
    public var myId: String? { ASFirebaseAuth.myID }
    public var room = CurrentValueSubject<Room?, Never>(nil)

    private let databaseManager: ASFirebaseDatabaseProtocol
    private let networkManager: ASNetworkManagerProtocol
    private var cancellables: Set<AnyCancellable> = []

    public init(databaseManager: ASFirebaseDatabaseProtocol, networkManager: ASNetworkManagerProtocol) {
        self.databaseManager = databaseManager
        self.networkManager = networkManager
    }

    public func connectRoom(roomNumber: String) {
        databaseManager.addRoomListener(roomNumber: roomNumber)
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
            .store(in: &cancellables)
    }

    public func disconnectRoom() {
        room.send(nil)
        databaseManager.removeRoomListener()
    }

    private func update<Value: Equatable>(
        _ keyPath: ReferenceWritableKeyPath<MainRepository, CurrentValueSubject<Value?, Never>>,
        with newValue: Value?
    ) {
        let subject = self[keyPath: keyPath]
        if subject.value != newValue {
            subject.send(newValue)
        }
    }

    public func postRecording(_ record: Data) async throws -> Bool {
        let queryItems = [URLQueryItem(name: "userId", value: ASFirebaseAuth.myID),
                          URLQueryItem(name: "roomNumber", value: room.value?.number)]
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
    
    public func postResetGame() async throws -> Bool {
        let queryItems = [URLQueryItem(name: "userId", value: ASFirebaseAuth.myID),
                          URLQueryItem(name: "roomNumber", value: room.value?.number)]
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
}
