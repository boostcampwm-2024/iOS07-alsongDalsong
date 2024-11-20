import ASEntity
import ASNetworkKit
import Combine
import Foundation

public final class MainRepository: MainRepositoryProtocol {
    
    public var number = PassthroughSubject<String?, Never>()
    public var host = PassthroughSubject<Player?, Never>()
    public var players = PassthroughSubject<[Player]?, Never>()
    public var mode = PassthroughSubject<ASEntity.Mode?, Never>()
    public var round = PassthroughSubject<UInt8?, Never>()
    public var status = PassthroughSubject<ASEntity.Status?, Never>()
    public var answers = PassthroughSubject<[ASEntity.Answer]?, Never>()
    public var dueTime = PassthroughSubject<Date?, Never>()
    public var submits = PassthroughSubject<[ASEntity.Answer]?, Never>()
    public var records = PassthroughSubject<[ASEntity.Record]?, Never>()
    public var selectedRecords = PassthroughSubject<[UInt8]?, Never>()
    
    private let databaseManager: ASFirebaseDatabaseProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    public init(databaseManager: ASFirebaseDatabaseProtocol) {
        self.databaseManager = databaseManager
    }
    
    public func connectRoom(roomNumber: String) {
        databaseManager.addRoomListener(roomNumber: roomNumber)
            .receive(on: DispatchQueue.global())
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
