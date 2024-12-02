import ASEntity
import ASRepositoryProtocol
import Combine
import Foundation

final class RehummingViewModel: @unchecked Sendable {
    @Published private(set) var dueTime: Date?
    @Published private(set) var recordOrder: UInt8?
    @Published private(set) var status: Status?
    @Published private(set) var submissionStatus: (submits: String, total: String) = ("0", "0")
    @Published private(set) var music: Music?
    @Published private(set) var recordedData: Data?
    @Published private(set) var isRecording: Bool = false

    private let gameStatusRepository: GameStatusRepositoryProtocol
    private let playersRepository: PlayersRepositoryProtocol
    private let recordsRepository: RecordsRepositoryProtocol
    private var cancellables: Set<AnyCancellable> = []

    init(
        gameStatusRepository: GameStatusRepositoryProtocol,
        playersRepository: PlayersRepositoryProtocol,
        recordsRepository: RecordsRepositoryProtocol
    ) {
        self.gameStatusRepository = gameStatusRepository
        self.playersRepository = playersRepository
        self.recordsRepository = recordsRepository
        bindGameStatus()
    }

    func submitHumming() async throws {
        guard let recordedData else { return }
        do {
            let result = try await recordsRepository.uploadRecording(recordedData)
            if result {
                // 전송됨
            } else {
                // 전송 안됨, 오류 alert
            }
        } catch {
            throw error
        }
    }

    func startRecording() {
        if !isRecording {
            isRecording = true
        }
    }

    func updateRecordedData(with data: Data) {
        // TODO: - data가 empty일 때(녹음이 제대로 되지 않았을 때 사용자 오류처리 필요
        guard !data.isEmpty else { return }
        recordedData = data
        isRecording = false
    }

    private func bindRecord(on recordOrder: UInt8) {
        recordsRepository.getHumming(on: recordOrder)
            .sink { [weak self] record in
                guard let record else { return }
                self?.music = Music(record)
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
                self?.bindRecord(on: newRecordOrder)
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
            .sink { [weak self] playersCount, recordsCount in
                let submitStatus = (submits: String(recordsCount), total: String(playersCount))
                self?.submissionStatus = submitStatus
            }
            .store(in: &cancellables)
    }
    
    func cancelSubscriptions() {
        cancellables.removeAll()
    }}
