import ASEntity
import ASRepositoryProtocol
import Combine
import Foundation

public final class HummingResultRepository: HummingResultRepositoryProtocol {
    private var mainRepository: MainRepositoryProtocol
    
    public init(
        mainRepository: MainRepositoryProtocol
    ) {
        self.mainRepository = mainRepository
    }
    
    public func getResult() -> AnyPublisher<[(answer: Answer, records: [ASEntity.Record], submit: Answer, recordOrder: UInt8)], Never> {
        mainRepository.room
            .compactMap { room in
                guard let room else { return [] }
                return room.answers?.map { answer in
                    let relatedRecords: [ASEntity.Record] = self.getRelatedRecords(for: answer,
                                                                                   from: room.records,
                                                                                   count: room.answers?.count ?? 0)
                    let relatedSubmit: Answer = self.getRelatedSubmit(for: answer, from: room.submits)
                    
                    return (answer: answer, records: relatedRecords, submit: relatedSubmit, recordOrder: room.recordOrder ?? 0)
                }
            }
            .receive(on: DispatchQueue.main)
            .removeDuplicates(by: { lhs, rhs in
                self.areResultsEqual(lhs: lhs, rhs: rhs)
            })
            .eraseToAnyPublisher()
    }
    
    private func getRelatedRecords(for answer: Answer, from records: [ASEntity.Record]?, count: Int) -> [ASEntity.Record] {
        var filteredRecords: [ASEntity.Record] = []

        for i in 0 ..< count {
            let tempCheck: Int = (((answer.player?.order ?? 0) + i) % count)
            if let filteredRecord = records?.first(where: { record in
                (tempCheck == record.player?.order) &&
                    (record.recordOrder ?? 0 == i)
            }) {
                filteredRecords.append(filteredRecord)
            }
        }

        return filteredRecords
    }

    private func getRelatedSubmit(for answer: Answer, from submits: [Answer]?) -> Answer {
        let temp = (answer.player?.order ?? 0) - 1 + (submits?.count ?? 0)
        let targetOrder = temp % (submits?.count == 0 ? 1 : submits?.count ?? 1)
        
        let submit = submits?.first(where: { submit in
            targetOrder == submit.player?.order
        })
        
        // TODO: nil 값에 대한 처리 필요
        return submit ?? Answer.answerStub1
    }
    
    public func getRecordData(url: URL) async throws -> Data {
        try await mainRepository.getResource(url: url)
    }
}

extension HummingResultRepository {
    private func areResultsEqual(
        lhs: [(answer: Answer, records: [ASEntity.Record], submit: Answer, recordOrder: UInt8)],
        rhs: [(answer: Answer, records: [ASEntity.Record], submit: Answer, recordOrder: UInt8)]
    ) -> Bool {
        guard lhs.count == rhs.count else { return false }
        for (index, lhsItem) in lhs.enumerated() {
            let rhsItem = rhs[index]
            if lhsItem.answer != rhsItem.answer ||
                lhsItem.records != rhsItem.records ||
                lhsItem.submit != rhsItem.submit ||
                lhsItem.recordOrder != rhsItem.recordOrder
            {
                return false
            }
        }
        return true
    }
}

public final class LocalHummingResultRepository: HummingResultRepositoryProtocol {
    public init() {}
    
    public func getResult() -> AnyPublisher<[(answer: Answer, records: [ASEntity.Record], submit: Answer, recordOrder: UInt8)], Never> {
        let tempAnswers = [Answer.answerStub1, Answer.answerStub2, Answer.answerStub3, Answer.answerStub4]
        let tempRecords = [
            ASEntity.Record.recordStub1_1, ASEntity.Record.recordStub1_2, ASEntity.Record.recordStub1_3,
            ASEntity.Record.recordStub2_1, ASEntity.Record.recordStub2_2, ASEntity.Record.recordStub2_3,
            ASEntity.Record.recordStub3_1, ASEntity.Record.recordStub3_2, ASEntity.Record.recordStub3_3,
            ASEntity.Record.recordStub4_1, ASEntity.Record.recordStub4_2, ASEntity.Record.recordStub4_3,
        ]
        let tempSubmits = [Answer.answerStub1, Answer.answerStub2, Answer.answerStub3, Answer.answerStub4]
        
        return Just(tempAnswers.map { answer in
            let relatedRecords = getRelatedRecords(for: answer, from: tempRecords, count: tempAnswers.count)
            let relatedSubmit = getRelatedSubmit(for: answer, from: tempSubmits)
            
            return (answer: answer, records: relatedRecords, submit: relatedSubmit, recordOrder: 0)
        })
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    private func getRelatedRecords(for answer: Answer, from records: [ASEntity.Record]?, count: Int) -> [ASEntity.Record] {
        var filteredRecords: [ASEntity.Record] = []

        for i in 0 ..< count {
            let tempCheck: Int = (((answer.player?.order ?? 0) + i) % count)
            if let filteredRecord = records?.first(where: { record in
                (tempCheck == record.player?.order) &&
                    (record.recordOrder ?? 0 == i)
            }) {
                filteredRecords.append(filteredRecord)
            }
        }
        
        return filteredRecords
    }

    private func getRelatedSubmit(for answer: Answer, from submits: [Answer]?) -> Answer {
        let temp = (answer.player?.order ?? 0) - 1 + (submits?.count ?? 0)
        let targetOrder = temp % (submits?.count ?? 0)
        let submit = submits?.first(where: { submit in
            targetOrder == submit.player?.order
        })

        return submit ?? Answer.answerStub1
    }
    
    public func getRecordData(url: URL) async throws -> Data {
        Data()
    }
}
