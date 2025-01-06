import ASEntity
import ASLogKit
import ASRepositoryProtocol
import Combine
import Foundation

final class HummingViewModel: @unchecked Sendable {
    @Published private(set) var dueTime: Date?
    @Published private(set) var recordOrder: UInt8?
    @Published private(set) var status: Status?
    @Published private(set) var submissionStatus: (submits: String, total: String) = ("0", "0")
    @Published private(set) var music: Music?
    @Published private(set) var recordedData: Data?
    @Published private(set) var isRecording: Bool = false

    private let gameStatusRepository: GameStatusRepositoryProtocol
    private let playersRepository: PlayersRepositoryProtocol
    private let answersRepository: AnswersRepositoryProtocol
    private let recordsRepository: RecordsRepositoryProtocol
    private var cancellables: Set<AnyCancellable> = []

    init(
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
        bindAnswer()
    }

    func didTappedRecordButton() {
        startRecording()
    }

    func didRecordingFinished(_ data: Data) {
        updateRecordedData(with: data)
    }

    func didTappedSubmitButton() {
        Task { await submitHumming() }
    }

    private func submitHumming() async {
        do {
            let result = try await recordsRepository.uploadRecording(recordedData ?? Data())
            if !result { Logger.error("Humming Did not sent") }
        } catch {
            Logger.error(error.localizedDescription)
        }
    }

    private func startRecording() {
        if !isRecording {
            isRecording = true
        }
    }

    private func updateRecordedData(with data: Data) {
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
                self?.bindSubmissionStatus(with: newRecordOrder)
            }
            .store(in: &cancellables)
        gameStatusRepository.getStatus()
            .sink { [weak self] newStatus in
                self?.status = newStatus
            }
            .store(in: &cancellables)
    }

    private func bindSubmissionStatus(with recordOrder: UInt8) {
        let playerPublisher = playersRepository.getPlayersCount()
        let recordsPublisher = recordsRepository.getRecordsCount(on: recordOrder)

        playerPublisher.combineLatest(recordsPublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] playersCount, recordsCount in
                let submitStatus = (submits: String(recordsCount), total: String(playersCount))
                self?.submissionStatus = submitStatus
            }
            .store(in: &cancellables)
    }
}
