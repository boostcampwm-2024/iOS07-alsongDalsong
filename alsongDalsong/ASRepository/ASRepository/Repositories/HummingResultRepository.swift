import Foundation
import Combine
import ASEntity

public final class HummingResultRepository: HummingResultRepositoryProtocol {
    private var mainRepository: MainRepositoryProtocol
    
    public init(mainRepository: MainRepositoryProtocol) {
        self.mainRepository = mainRepository
    }
    
    public func getResult() -> AnyPublisher<[(answer: Answer, records: [ASEntity.Record], submit: Answer)], Never> {
        Publishers.CombineLatest3(mainRepository.answers, mainRepository.records, mainRepository.submits)
            .compactMap { answers, records, submits in
                answers?.map { answer in
                    let relatedRecords: [ASEntity.Record] = self.getRelatedRecords(for: answer,
                                                                                   from: records,
                                                                                   count: answers?.count ?? 0)
                    let relatedSubmit: Answer = self.getRelatedSubmit(for: answer, from: submits)
                    return (answer: answer, records: relatedRecords, submit: relatedSubmit)
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private func getRelatedRecords(for answer: Answer, from records: [ASEntity.Record]?, count: Int) -> [ASEntity.Record] {
        var filteredRecords: [ASEntity.Record] = []

        for i in 0 ..< count {
            if let filteredRecord = records?.first(where: { record in
                ((((answer.player?.order ?? 0) + i) % count) == record.player?.order) &&
                (record.round == i)
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
        
        //TODO: nil 값에 대한 처리 필요
        return submit ?? Answer.answerStub1
    }
}

public final class LocalHummingResultRepository: HummingResultRepositoryProtocol {
    public init() {}
    
    public func getResult() -> AnyPublisher<[(answer: Answer, records: [ASEntity.Record], submit: Answer)], Never> {
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
            
            return (answer: answer, records: relatedRecords, submit: relatedSubmit)
        })
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    private func getRelatedRecords(for answer: Answer, from records: [ASEntity.Record]?, count: Int) -> [ASEntity.Record] {
        var filteredRecords: [ASEntity.Record] = []

        for i in 0 ..< count {
            if let filteredRecord = records?.first(where: { record in
                ((((answer.player?.order ?? 0) + i) % count) == record.player?.order) &&
                (record.round == i)
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
}
