import Foundation
import Combine
import ASRepository
import ASAudioKit
import ASEntity

final class HummingResultViewModel {
    private let player = ASAudioPlayer()
    private var answerRepository: AnswersRepositoryProtocol
    private var recordsRepository: RecordsRepositoryProtocol
    private var submitsRepository: SubmitsRepositoryProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var currentResult: testAnswer?
    @Published var resultRecords: [ASEntity.Record] = []
    @Published var answer: testAnswer?
    
    // 미리 받아놓을 정보 배열(2차원) ([(선택된 음악: [record, record]), ...])
    private var answerResult: [ASEntity.Answer] = []
    private var recordsResult: [ASEntity.Record] = []
    
    init(answerRepository: AnswersRepositoryProtocol,
         recordsRepository: RecordsRepositoryProtocol,
         submitsRepository: SubmitsRepositoryProtocol) {
        self.answerRepository = answerRepository
        self.recordsRepository = recordsRepository
        self.submitsRepository = submitsRepository
    }
    
    func fetchResult() {
        currentResult = testAnswer(player: .init(id: "2134"),
                                   music: .init(title: "허각", artist: "Hello"),
                                   playlist: .init())
        resultRecords = [
            ASEntity.Record(),
            ASEntity.Record(),
            ASEntity.Record()
        ]
        
        answer = testAnswer(player: .init(id: "2134"),
                             music: .init(title: "허각", artist: "Hello"),
                             playlist: .init())
        
        answerRepository.getAnswers()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                //TODO: 성공 실패 여부에 따른 처리
            } receiveValue: { [weak self] answers in
                let orderedAnswers = answers.sorted { answer0, answer1 in
                    if let player0 = answer0.player, let player1 = answer1.player {
                        return player0.order ?? 0 < player1.order ?? 1
                    }
                    return 0 < 1
                }
                self?.answerResult = orderedAnswers
            }
            .store(in: &cancellables)

        recordsRepository.getRecords()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                //TODO: 성공 실패 여부에 따른 처리
            } receiveValue: { [weak self] records in
                let orderedRecords = records.sorted { record0, record1 in
                    record0.round ?? 0 < record1.round ?? 1
                }
                self?.recordsResult = orderedRecords
            }
            .store(in: &cancellables)

    }
}

struct testAnswer {
    let player: Player
    let music: Music
    let playlist: Playlist
    
    init(player: Player, music: Music, playlist: Playlist) {
        self.player = player
        self.music = music
        self.playlist = playlist
    }
}
