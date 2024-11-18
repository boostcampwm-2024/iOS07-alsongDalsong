import ASEntity
import ASNetworkKit
import Combine
import Foundation

public final class MainRepository {
    private let firebaseManager = ASFirebaseManager()

    @PublishedValue public var number: String?
    @PublishedValue public var host: Player?
    @PublishedValue public var players: [Player]?
    @PublishedValue public var mode: Mode?
    @PublishedValue public var round: UInt8?
    @PublishedValue public var status: Status?
    @PublishedValue public var records: [ASEntity.Record]?
    @PublishedValue public var answers: [Answer]?
    @PublishedValue public var dueTime: Date?
    @PublishedValue public var selectedRecords: [UInt8]?
    @PublishedValue public var submits: [Answer]?
    
    private var cancellables: Set<AnyCancellable> = []
    
    public init(roomNumber: String) {
        connectRoom(roomNumber: roomNumber)
    }
    
    public func connectRoom(roomNumber: String) {
        firebaseManager.addRoomListener(roomNumber: roomNumber)
            .receive(on: DispatchQueue.global())
            .sink { completion in
                switch completion {
                case .failure(let error):
                    // TODO:- Error Handling
                    print(error.localizedDescription)
                case .finished:
                    return
                }
            } receiveValue: { [weak self] room in
                self?.number = room.number
                self?.host = room.host
                self?.players = room.players
                self?.mode = room.mode
                self?.round = room.round
                self?.status = room.status
//                self?.records = room.records
                self?.answers = room.answers
                self?.dueTime = room.dueTime
                self?.selectedRecords = room.selectedRecords
                self?.submits = room.submits
            }
            .store(in: &cancellables)
    }
}
