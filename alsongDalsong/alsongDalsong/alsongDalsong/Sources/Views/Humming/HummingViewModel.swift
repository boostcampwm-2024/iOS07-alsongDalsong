import ASEntity
import ASRepository
import Combine
import Foundation

final class HummingViewModel: @unchecked Sendable {
    @Published public private(set) var dueTime: Date?
    @Published public private(set) var round: UInt8?
    @Published public private(set) var status: Status?
    @Published public private(set) var submissionStatus: (submits: String, total: String) = ("0", "0")
    @Published public private(set) var music: Music?
    @Published public private(set) var recordedData: Data?
    @Published public private(set) var isRecording: Bool = false

    private let gameStatusRepository: GameStatusRepositoryProtocol
    private let playersRepository: PlayersRepositoryProtocol
    private let answersRepository: AnswersRepositoryProtocol
    private let submitsRepository: SubmitsRepositoryProtocol
    private var cancellables: Set<AnyCancellable> = []

    public init(
        gameStatusRepository: GameStatusRepositoryProtocol,
        playersRepository: PlayersRepositoryProtocol,
        answersRepository: AnswersRepositoryProtocol,
        submitsRepository: SubmitsRepositoryProtocol
    ) {
        self.gameStatusRepository = gameStatusRepository
        self.playersRepository = playersRepository
        self.answersRepository = answersRepository
        self.submitsRepository = submitsRepository
        bindGameStatus()
        bindSubmitStatus()
        bindAnswer()
    }

    // TODO: - FB에 humming 보내기
    func submitHumming() {
        var myHumming = ASEntity.Record()
    }

    func startRecording() {
        isRecording = true
    }

    func togglePlayPause() {
        Task {
            await AudioHelper.shared.startPlaying(file: recordedData)
        }
    }

    func updateRecordedData(with data: Data) {
        // TODO: - data가 empty일 때(녹음이 제대로 되지 않았을 때 사용자 오류처리 필요
        guard !data.isEmpty else { return }
        recordedData = data
        isRecording = false
    }
    
    private func bindAnswer() {
        answersRepository.getMyAnswer()
            .eraseToAnyPublisher()
            .sink { [weak self] answer in
                self?.music = answer?.music
            }
            .store(in: &cancellables)
    }

    private func bindGameStatus() {
        gameStatusRepository.getDueTime()
            .sink { [weak self] newDueTime in
                self?.dueTime = newDueTime
            }
            .store(in: &cancellables)
        gameStatusRepository.getRound()
            .sink { [weak self] newRound in
                self?.round = newRound
            }
            .store(in: &cancellables)
        gameStatusRepository.getStatus()
            .sink { [weak self] newStatus in
                self?.status = newStatus
            }
            .store(in: &cancellables)
    }

    private func bindSubmitStatus() {
        let playerPublisher = playersRepository.getPlayers()
        let submitsPublisher = submitsRepository.getSubmits()

        playerPublisher.zip(submitsPublisher)
            .sink { [weak self] players, submits in
                let submitStatus = (submits: String(submits.count), total: String(players.count))
                self?.submissionStatus = submitStatus
            }
            .store(in: &cancellables)
    }
}
