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
    @Published var currentRecords: [ASEntity.Record] = []
    @Published var currentsubmit: Answer?
    
    // 미리 받아놓을 정보 배열(2차원) ([(선택된 음악: [record, record]), ...])
    private var recordsResult: [ASEntity.Record] = []
    private var submitsResult: Answer?
    
    var hummingResult: [(answer: ASEntity.Answer, records: [ASEntity.Record], submit: ASEntity.Answer)] = []
    
    init(hummingResultRepository: HummingResultRepositoryProtocol) {
        self.hummingResultRepository = hummingResultRepository
        fetchResult()
    }
    
    private func fetchResult() {
        hummingResultRepository.getResult()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                //TODO: 성공 실패 여부에 따른 처리
                print(completion)
            } receiveValue: { [weak self] (result: [(answer: ASEntity.Answer, records: [ASEntity.Record], submit: ASEntity.Answer)]) in
                self?.hummingResult = result.sorted {
                    $0.answer.player?.order ?? 0 < $1.answer.player?.order ?? 1
                }
                guard let current = self?.hummingResult.removeFirst() else { return }
                self?.currentResult = current.answer
                self?.recordsResult = current.records
                self?.submitsResult = current.submit
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    func startPlaying() {
        //TODO: 현재 file은 Data타입이나 URL타입으로 바뀔 예정, 추후 로직 수정 필요
        Task {
            while !recordsResult.isEmpty {
                currentRecords.append(recordsResult.removeFirst())
                await AudioHelper.shared.startPlaying(file: currentRecords.last?.file)
                await waitForPlaybackToFinish()
            }
            currentsubmit = submitsResult
        }
    }
    
    private func waitForPlaybackToFinish() async {
        await withCheckedContinuation { continuation in
            Task {
                while await AudioHelper.shared.isPlaying() {
                    // 재생이 끝날 때까지 대기
                    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1초
                }
                continuation.resume()
            }
        }
    }
    
    func nextResultFetch() {
        let current = self.hummingResult.removeFirst()
        
        self.currentResult = current.answer
        self.recordsResult = current.records
        self.submitsResult = current.submit
        self.currentRecords.removeAll()
        self.currentsubmit = nil
    }
}
