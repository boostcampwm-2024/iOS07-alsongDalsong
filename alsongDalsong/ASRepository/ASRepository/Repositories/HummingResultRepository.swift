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
                    let relatedRecords: [ASEntity.Record] = self.getRelatedRecords(for: answer, from: records)
                    let relatedSubmit: Answer = self.getRelatedSubmit(for: answer, from: submits)
                    return (answer: answer, records: relatedRecords, submit: relatedSubmit)
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private func getRelatedRecords(for answer: Answer, from records: [ASEntity.Record]?) -> [ASEntity.Record] {
        return records?.filter { $0.player?.id != answer.player?.id }
            .sorted { ($0.player?.order ?? 0) < ($1.player?.order ?? 1) } ?? []
    }

    private func getRelatedSubmit(for answer: Answer, from submits: [Answer]?) -> Answer {
        //TODO: answer에 대한 답을 제시한 submit 찾기
        return Answer.answerStub1
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
            let relatedRecords = getRelatedRecords(for: answer, from: tempRecords)
            let relatedSubmit = tempSubmits.first!
            return (answer: answer, records: relatedRecords, submit: relatedSubmit)
        })
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    private func getRelatedRecords(for answer: Answer, from records: [ASEntity.Record]?) -> [ASEntity.Record] {
        guard let records else {return []}
        let record1 = records.first { (((answer.player?.order ?? 0) % 4) == $0.player?.order) && ($0.round == 1) }
        let record2 = records.first { ((((answer.player?.order ?? 0) + 1) % 4) == $0.player?.order) && ($0.round == 2) }
        let record3 = records.first { ((((answer.player?.order ?? 0) + 2) % 4) == $0.player?.order) && ($0.round == 3) }
        if let record1,
           let record2,
           let record3 {
            return [record1, record2, record3]
        }
        return []
    }

}
