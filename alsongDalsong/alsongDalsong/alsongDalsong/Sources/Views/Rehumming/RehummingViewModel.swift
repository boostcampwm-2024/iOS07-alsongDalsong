import ASEntity
import ASRepository
import Combine
import Foundation

final class RehummingViewModel {
    @Published public private(set) var dueTime: Date?
    @Published public private(set) var round: UInt8?
    @Published public private(set) var status: Status?
    @Published public private(set) var submissionStatus: (submits: String, total: String) = ("0", "0")
    @Published public private(set) var humming: Data?
    @Published public private(set) var rehumming: Data?

    private let gameStatusRepository: GameStatusRepositoryProtocol
    private let playersRepository: PlayersRepositoryProtocol
    private let recordsRepository: RecordsRepositoryProtocol
    private let submitsRepository: SubmitsRepositoryProtocol
    private var cancellables: Set<AnyCancellable> = []

    public init(
        gameStatusRepository: GameStatusRepositoryProtocol,
        playersRepository: PlayersRepositoryProtocol,
        recordsRepository: RecordsRepositoryProtocol,
        submitsRepository: SubmitsRepositoryProtocol
    ) {
        self.gameStatusRepository = gameStatusRepository
        self.playersRepository = playersRepository
        self.recordsRepository = recordsRepository
        self.submitsRepository = submitsRepository
        bindGameStatus()
        bindSubmitStatus()
        bindHumming()
    }

    func bindGameStatus() {
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

    func bindSubmitStatus() {
        let playerPublisher = playersRepository.getPlayers()
        let submitsPublisher = submitsRepository.getSubmits()

        playerPublisher.zip(submitsPublisher)
            .sink { [weak self] players, submits in
                let submitStatus = (submits: String(submits.count),
                                    total: String(players.count))
                self?.submissionStatus = submitStatus
            }
            .store(in: &cancellables)
    }

    func bindHumming() {
        recordsRepository.getHumming(on: round ?? 0)
            .sink { [weak self] newHumming in
                self?.humming = newHumming
            }
            .store(in: &cancellables)
    }

    @MainActor
    func startRecording() {
        Task {
            let data = await AudioHelper.shared.startRecording()
            rehumming = data
        }
    }

    @MainActor
    func startPlaying(_ type: HummingType) {
        Task {
            await AudioHelper.shared.startPlaying(
                file: type == .humming ? humming : rehumming
            )
        }
    }

    enum HummingType {
        case humming, rehumming
    }
}
