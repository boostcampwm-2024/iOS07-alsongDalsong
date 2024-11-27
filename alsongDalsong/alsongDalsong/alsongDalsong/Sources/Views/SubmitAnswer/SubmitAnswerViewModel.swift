import ASEntity
import ASMusicKit
import ASRepository
import Combine
import Foundation
import MusicKit

final class SubmitAnswerViewModel: ObservableObject, @unchecked Sendable {
    @Published public private(set) var searchList: [Music] = []
    @Published public private(set) var selectedMusic: Music?
    @Published public private(set) var dueTime: Date?
    @Published public private(set) var recordOrder: UInt8?
    @Published public private(set) var status: Status?
    @Published public private(set) var submissionStatus: (submits: String, total: String) = ("0", "0")
    @Published public private(set) var music: Music?
    @Published public private(set) var recordedData: Data?
    @Published public private(set) var isRecording: Bool = false
    @Published public private(set) var musicData: Data? {
        didSet { isPlaying = true }
    }

    @Published public private(set) var isPlaying: Bool = false {
        didSet { isPlaying ? playingMusic() : stopMusic() }
    }

    private let musicRepository: MusicRepositoryProtocol
    private let gameStatusRepository: GameStatusRepositoryProtocol
    private let playersRepository: PlayersRepositoryProtocol
    private let recordsRepository: RecordsRepositoryProtocol
    private let submitsRepository: SubmitsRepositoryProtocol

    private let musicAPI = ASMusicAPI()
    private var cancellables: Set<AnyCancellable> = []

    init(
        gameStatusRepository: GameStatusRepositoryProtocol,
        playersRepository: PlayersRepositoryProtocol,
        recordsRepository: RecordsRepositoryProtocol,
        submitsRepository: SubmitsRepositoryProtocol,
        musicRepository: MusicRepositoryProtocol
    ) {
        self.gameStatusRepository = gameStatusRepository
        self.playersRepository = playersRepository
        self.recordsRepository = recordsRepository
        self.submitsRepository = submitsRepository
        self.musicRepository = musicRepository
        bindGameStatus()
        bindSubmitStatus()
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
    
    public func playingMusic() {
        guard let data = musicData else { return }
        Task {
            await AudioHelper.shared.startPlaying(file: data)
        }
    }

    public func stopMusic() {
        Task {
            await AudioHelper.shared.stopPlaying()
        }
    }

    public func downloadArtwork(url: URL?) async -> Data? {
        guard let url else { return nil }
        return await musicRepository.getMusicData(url: url)
    }

    @MainActor
    public func downloadMusic(url: URL) {
        Task {
            musicData = await musicRepository.getMusicData(url: url)
        }
    }

    @MainActor
    public func searchMusic(text: String) {
        Task {
            if text.isEmpty { return }
            searchList = await musicAPI.search(for: text)
        }
    }

    @MainActor
    public func handleSelectedMusic(with music: Music) {
        selectedMusic = music
        beginPlaying()
    }

    @MainActor
    private func beginPlaying() {
        guard let previewUrl = selectedMusic?.previewUrl else { return }
        downloadMusic(url: previewUrl)
    }

    public func submitAnswer() async throws {
        guard let selectedMusic else { return }
        do {
            let response = try await submitsRepository.submitAnswer(answer: selectedMusic)
        } catch {
            throw error
        }
    }

    // MARK: - 이부분 부터 RehummingViewModel

    public func startRecording() {
        isRecording = true
    }

    public func togglePlayPause() {
        Task {
            await AudioHelper.shared.startPlaying(file: recordedData)
        }
    }

    public func updateRecordedData(with data: Data) {
        // TODO: - data가 empty일 때(녹음이 제대로 되지 않았을 때 사용자 오류처리 필요
        guard !data.isEmpty else { return }
        recordedData = data
        isRecording = false
    }
}
