import ASEntity
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

    public func getHumming(on round: UInt8) -> AnyPublisher<Data?, Never> {
        // 임시로 내가 몇 번째 player인지 인식하는 인덱스
        let myIndex = 1
        let playersCount = 4
        return mainRepository.records
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .map { records in
                let index = (myIndex - 1 + playersCount) % playersCount
                let hummings = records.filter { $0.recordOrder ?? 0 == (round - 1) }
                return (index < hummings.count) ? hummings[index].file : Data()
            }
            .eraseToAnyPublisher()
    }
}
