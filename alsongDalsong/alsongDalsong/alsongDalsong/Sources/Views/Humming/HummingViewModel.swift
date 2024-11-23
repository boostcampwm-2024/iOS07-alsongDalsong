import ASEntity
import ASRepository
import Combine
import Foundation

final class HummingViewModel: ObservableObject, @unchecked Sendable {
    @Published public private(set) var dueTime: Date?
    @Published public private(set) var round: UInt8?
    @Published public private(set) var status: Status?
    @Published public private(set) var submissionStatus: (submits: String, total: String) = ("0", "0")
    @Published public private(set) var humming: Data?
    @Published public private(set) var recorderAmplitude: Float = 0.0

    private let gameStatusRepository: GameStatusRepositoryProtocol
    private let playersRepository: PlayersRepositoryProtocol
    private let submitsRepository: SubmitsRepositoryProtocol
    private var cancellables: Set<AnyCancellable> = []

    public init(
        gameStatusRepository: GameStatusRepositoryProtocol,
        playersRepository: PlayersRepositoryProtocol,
        submitsRepository: SubmitsRepositoryProtocol
    ) {
        self.gameStatusRepository = gameStatusRepository
        self.playersRepository = playersRepository
        self.submitsRepository = submitsRepository
        bindGameStatus()
        bindSubmitStatus()
        bindAmplitudeUpdates()
    }

    private func bindAmplitudeUpdates() {
        Task {
            await AudioHelper.shared.amplitudePubisher()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] newAmplitude in
                    guard let self = self else { return }
                    self.recorderAmplitude = newAmplitude
                }
                .store(in: &self.cancellables)
        }
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

    // TODO: - FB에 humming 보내기
    func submitHumming() {
        var myHumming = ASEntity.Record()
        myHumming.file = humming
//        myHumming.player = me
//        myHumming.round = round
    }

    @MainActor
    func startRecording() {
        Task {
            let data = await AudioHelper.shared.startRecording()
            humming = data
        }
    }

    @MainActor
    func startPlaying() {
        Task {
            await AudioHelper.shared.startPlaying(file: humming)
        }
    }
}