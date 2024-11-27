import ASDecoder
import ASEncoder
import ASEntity
import ASNetworkKit
import Combine
import Foundation

public final class MainRepository: MainRepositoryProtocol {
    public var myId = ASFirebaseAuth.myID
    public var number = CurrentValueSubject<String?, Never>(nil)
    public var host = CurrentValueSubject<Player?, Never>(nil)
    public var players = CurrentValueSubject<[Player]?, Never>(nil)
    public var mode = CurrentValueSubject<ASEntity.Mode?, Never>(nil)
    public var round = CurrentValueSubject<UInt8?, Never>(nil)
    public var status = CurrentValueSubject<ASEntity.Status?, Never>(nil)
    public var recordOrder = CurrentValueSubject<UInt8?, Never>(nil)
    public var answers = CurrentValueSubject<[ASEntity.Answer]?, Never>(nil)
    public var dueTime = CurrentValueSubject<Date?, Never>(nil)
    public var submits = CurrentValueSubject<[ASEntity.Answer]?, Never>(nil)
    public var records = CurrentValueSubject<[ASEntity.Record]?, Never>(nil)
    public var selectedRecords = CurrentValueSubject<[UInt8]?, Never>(nil)

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
                        print(error.localizedDescription)
                    case .finished:
                        return
                }
            } receiveValue: { [weak self] room in
                guard let self = self else { return }
                self.update(\.number, with: room.number)
                self.update(\.host, with: room.host)
                self.update(\.players, with: room.players)
                self.update(\.mode, with: room.mode)
                self.update(\.round, with: room.round)
                self.update(\.status, with: room.status)
                self.update(\.recordOrder, with: room.recordOrder)
                self.update(\.answers, with: room.answers)
                self.update(\.dueTime, with: room.dueTime)
                self.update(\.submits, with: room.submits)
                self.update(\.records, with: room.records)
                self.update(\.selectedRecords, with: room.selectedRecords)
            }
            .store(in: &cancellables)
    }

    public func disconnectRoom() {
        update(\.number, with: nil)
        update(\.host, with: nil)
        update(\.players, with: nil)
        update(\.mode, with: nil)
        update(\.round, with: nil)
        update(\.status, with: nil)
        update(\.recordOrder, with: nil)
        update(\.answers, with: nil)
        update(\.dueTime, with: nil)
        update(\.submits, with: nil)
        update(\.records, with: nil)
        update(\.selectedRecords, with: nil)
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
                          URLQueryItem(name: "roomNumber", value: number.value)]
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
}
