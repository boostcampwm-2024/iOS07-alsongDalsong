import ASEntity
import ASNetworkKit
import Combine
import Foundation

public final class MainRepository: MainRepositoryProtocol {
    
    public var number = CurrentValueSubject<String?, Never>(nil)
    public var host = CurrentValueSubject<Player?, Never>(nil)
    public var players = CurrentValueSubject<[Player]?, Never>(nil)
    public var mode = CurrentValueSubject<ASEntity.Mode?, Never>(nil)
    public var round = CurrentValueSubject<UInt8?, Never>(nil)
    public var status = CurrentValueSubject<ASEntity.Status?, Never>(nil)
    public var answers = CurrentValueSubject<[ASEntity.Answer]?, Never>(nil)
    public var dueTime = CurrentValueSubject<Date?, Never>(nil)
    public var submits = CurrentValueSubject<[ASEntity.Answer]?, Never>(nil)
    public var records = CurrentValueSubject<[ASEntity.Record]?, Never>(nil)
    public var selectedRecords = CurrentValueSubject<[UInt8]?, Never>(nil)
    
    private let databaseManager: ASFirebaseDatabaseProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    public init(databaseManager: ASFirebaseDatabaseProtocol) {
        self.databaseManager = databaseManager
    }
    
    public func connectRoom(roomNumber: String) {
        databaseManager.addRoomListener(roomNumber: roomNumber)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    // TODO: - Error Handling
                    print(error.localizedDescription)
                case .finished:
                    return
                }
            } receiveValue: { [weak self] room in
                print(room)
                guard let self = self else { return }
                self.update(\.number, with: room.number)
                self.update(\.host, with: room.host)
                self.update(\.players, with: room.players)
                self.update(\.mode, with: room.mode)
                self.update(\.round, with: room.round)
                self.update(\.status, with: room.status)
                self.update(\.answers, with: room.answers)
                self.update(\.dueTime, with: room.dueTime)
                self.update(\.submits, with: room.submits)
                self.update(\.records, with: room.records)
                self.update(\.selectedRecords, with: room.selectedRecords)
            }
            .store(in: &cancellables)
    }
    
    public func disconnectRoom() {
        self.update(\.number, with: nil)
        self.update(\.host, with: nil)
        self.update(\.players, with: nil)
        self.update(\.mode, with: nil)
        self.update(\.round, with: nil)
        self.update(\.status, with: nil)
        self.update(\.answers, with: nil)
        self.update(\.dueTime, with: nil)
        self.update(\.submits, with: nil)
        self.update(\.records, with: nil)
        self.update(\.selectedRecords, with: nil)
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
}
