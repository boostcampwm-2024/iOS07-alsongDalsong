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
