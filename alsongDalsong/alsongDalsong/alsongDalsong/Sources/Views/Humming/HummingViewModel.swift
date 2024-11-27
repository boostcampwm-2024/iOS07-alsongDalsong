import ASEntity
import ASRepository
import Combine
import Foundation

final class HummingViewModel: @unchecked Sendable {
    @Published public private(set) var dueTime: Date?
    @Published public private(set) var recordOrder: UInt8?
    @Published public private(set) var status: Status?
    @Published public private(set) var submissionStatus: (submits: String, total: String) = ("0", "0")
    @Published public private(set) var music: Music?
    @Published public private(set) var recordedData: Data?
    @Published public private(set) var isRecording: Bool = false

    private let gameStatusRepository: GameStatusRepositoryProtocol
    private let playersRepository: PlayersRepositoryProtocol
    private let answersRepository: AnswersRepositoryProtocol
    private let recordsRepository: RecordsRepositoryProtocol
    private var cancellables: Set<AnyCancellable> = []

    public init(
        gameStatusRepository: GameStatusRepositoryProtocol,
        playersRepository: PlayersRepositoryProtocol,
        answersRepository: AnswersRepositoryProtocol,
        recordsRepository: RecordsRepositoryProtocol
    ) {
        self.gameStatusRepository = gameStatusRepository
        self.playersRepository = playersRepository
        self.answersRepository = answersRepository
        self.recordsRepository = recordsRepository
        bindGameStatus()
        bindSubmitStatus()
        bindAnswer()
    }

    func submitHumming() {
        guard let recordedData else { return }
        Task {
            do {
                let result = try await recordsRepository.uploadRecording(recordedData)
                if result {
                    // 전송됨
                } else {
                    // 전송 안됨, 오류 alert
                }
            } catch {
                // 전송 안됨, 오류 alert
            }
        }
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
        gameStatusRepository.getRecordOrder()
            .sink { [weak self] newRecordOrder in
                self?.recordOrder = newRecordOrder
            }
            .store(in: &cancellables)
        gameStatusRepository.getStatus()
            .sink { [weak self] newStatus in
                self?.status = newStatus
            }
            .store(in: &cancellables)
    }

    private func bindSubmitStatus() {
        let playerPublisher = playersRepository.getPlayersCount()
        let recordsPublisher = recordsRepository.getRecordsCount(on: Int(recordOrder ?? 0))

        playerPublisher.combineLatest(recordsPublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] playersCount, recordsCount in
                let submitStatus = (submits: String(recordsCount), total: String(playersCount))
                self?.submissionStatus = submitStatus
            }
            .store(in: &cancellables)
    }
}
