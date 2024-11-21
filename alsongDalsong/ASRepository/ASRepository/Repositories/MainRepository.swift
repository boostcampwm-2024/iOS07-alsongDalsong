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
                guard let self = self else { return }
                self.number.send(room.number)
                self.host.send(room.host)
                self.players.send(room.players)
                self.mode.send(room.mode)
                self.round.send(room.round)
                self.status.send(room.status)
                self.answers.send(room.answers)
                self.dueTime.send(room.dueTime)
                self.submits.send(room.submits)
            }
            .store(in: &cancellables)
    }
}
