import ASEntity
import ASLogKit
import ASRepositoryProtocol
import Combine
import Foundation

public final class RecordsRepository: RecordsRepositoryProtocol {
    private var mainRepository: MainRepositoryProtocol

    public init(mainRepository: MainRepositoryProtocol) {
        self.mainRepository = mainRepository
    }

    public func getRecords() -> AnyPublisher<[ASEntity.Record], Never> {
        mainRepository.room
            .receive(on: DispatchQueue.main)
            .compactMap { $0?.records }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    public func getRecordsCount(on recordOrder: UInt8) -> AnyPublisher<Int, Never> {
        getRecords()
            .compactMap { $0 }
            .map { records in
                records.filter { Int($0.recordOrder ?? 0) == recordOrder }
            }
            .map(\.count)
            .eraseToAnyPublisher()
    }

    public func getHumming(on recordOrder: UInt8) -> AnyPublisher<ASEntity.Record?, Never> {
        mainRepository.room
            .receive(on: DispatchQueue.main)
            .compactMap { room in
                guard let room else { return nil }
                return (room.records, room.players)
            }
            .map { [weak self] records, players -> ASEntity.Record? in
                self?.findRecord(
                    records: records,
                    players: players,
                    recordOrder: recordOrder
                )
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    public func uploadRecording(_ record: Data) async throws -> Bool {
        try await mainRepository.postRecording(record)
    }

    private func findRecord(records: [ASEntity.Record]?,
                            players: [Player]?,
                            recordOrder: UInt8) -> ASEntity.Record?
    {
        guard let records, let players,
              !players.isEmpty,
              recordOrder > 0,
              let myId = mainRepository.myId,
              let myOrder = players.first(where: { $0.id == myId })?.order
        else { return nil }

        let targetOrder = findTargetOrder(for: myOrder, in: players.count)
        let targetId = players.first(where: { $0.order == targetOrder })?.id
        let hummings = findHummings(for: recordOrder, in: records)

        if let targetRecord = hummings.first(where: { $0.player?.id == targetId }) {
            return targetRecord
        } else {
            Logger.debug("\(targetId)에 대한 Record를 찾을 수 없음")
            return nil
        }
    }

    private func findTargetOrder(for myOrder: Int, in playersCount: Int) -> Int {
        (myOrder - 1 + playersCount) % playersCount
    }

    private func findHummings(for recordOrder: UInt8, in records: [ASEntity.Record]) -> [ASEntity.Record] {
        records.filter { $0.recordOrder == (recordOrder - 1) }
    }
}
