import Foundation
import Combine
import ASRepository
import ASAudioKit
import ASEntity

final class HummingResultViewModel {
    private let player = ASAudioPlayer()
    private var hummingResultRepository: HummingResultRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    @Published var currentResult: Answer?
    @Published var resultRecords: [ASEntity.Record] = []
    @Published var answer: Answer?
    
    // 미리 받아놓을 정보 배열(2차원) ([(선택된 음악: [record, record]), ...])
    private var answerResult: [ASEntity.Answer] = []
    private var recordsResult: [ASEntity.Record] = []
    private var hummingResult: [(answer: ASEntity.Answer, records: [ASEntity.Record], submit: ASEntity.Answer)] = []
    
    init(hummingResultRepository: HummingResultRepositoryProtocol) {
        self.hummingResultRepository = hummingResultRepository
        fetchResult()
    }
    
    func fetchResult() {
        hummingResultRepository.getResult()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                //TODO: 성공 실패 여부에 따른 처리
                print(completion)
            } receiveValue: { [weak self] (result: [(answer: ASEntity.Answer, records: [ASEntity.Record], submit: ASEntity.Answer)]) in
                self?.hummingResult = result.sorted {
                    $0.answer.player?.order ?? 0 < $1.answer.player?.order ?? 1
                }
                let current = self?.hummingResult.removeFirst()
                self?.currentResult = current?.answer
                self?.resultRecords = current?.records ?? []
                self?.answer = current?.answer
            }
            .store(in: &cancellables)
    }
}
