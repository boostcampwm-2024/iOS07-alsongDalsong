import ASDecoder
import ASEncoder
import ASEntity
import ASNetworkKit
import Combine
import Foundation

public final class RecordsRepository: RecordsRepositoryProtocol {
    private var mainRepository: MainRepositoryProtocol

    public init(mainRepository: MainRepositoryProtocol) {
        self.mainRepository = mainRepository
    }

    public func getRecords() -> AnyPublisher<[ASEntity.Record], Never> {
        mainRepository.records
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    public func getRecordsCount(on recordOrder: Int) -> AnyPublisher<Int, Never> {
        mainRepository.records
            .compactMap { $0 }
            .map { records in
                records.filter { Int($0.recordOrder ?? 0) == recordOrder }
            }
            .map { $0.count }
            .eraseToAnyPublisher()
    }

    public func getHumming(on recordOrder: UInt8) -> AnyPublisher<ASEntity.Record?, Never> {
        let recordsPublisher = mainRepository.records
        let playersPublisher = mainRepository.players
        return recordsPublisher
            .combineLatest(playersPublisher)
            .map { [weak self] records, players -> ASEntity.Record? in
                guard let records, let players else { return nil }
                let myId = self?.mainRepository.myId
                guard let myIndex = players.firstIndex(where: { $0.id == myId }) else { return nil }
                let playersCount = players.count
                let targetIndex = (myIndex - 1 + playersCount) % playersCount
                guard playersCount > targetIndex else { return nil }
                let targetId = players[targetIndex].id
                let hummings = records.filter { $0.recordOrder == (recordOrder - 1) }

                return hummings.first(where: { $0.player?.id == targetId })
            }
            .eraseToAnyPublisher()
    }

    public func uploadRecording(_ record: Data) async throws -> Bool {
        return try await mainRepository.postRecording(record)
    }
}
