import ASEntity
import ASRepository
import Combine
import Foundation

final class HummingViewModel {
    @Published public private(set) var dueTime: Date?
    @Published public private(set) var round: UInt8?
    @Published public private(set) var status: Status?
    @Published public private(set) var submitStatus: (submits: Int, total: Int)?

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
                let submitStatus = (submits: submits.count, total: players.count)
                self?.submitStatus = submitStatus
            }
            .store(in: &cancellables)
    }
}