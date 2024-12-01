import ASEntity
import ASMusicKit
import ASRepositoryProtocol
import Combine
import Foundation

final class SelectMusicViewModel: ObservableObject, @unchecked Sendable {
    @Published public private(set) var answers: [Answer] = []
    @Published public private(set) var searchList: [Music] = []
    @Published public private(set) var dueTime: Date?
    @Published public private(set) var selectedMusic: Music?
    @Published public private(set) var submissionStatus: (submits: String, total: String) = ("0", "0")

    @Published public private(set) var musicData: Data? {
        didSet { isPlaying = true }
    }

    @Published public var isPlaying: Bool = false {
        didSet { isPlaying ? playMusic() : stopMusic() }
    }
    
    private let musicRepository: MusicRepositoryProtocol
    private let playersRepository: PlayersRepositoryProtocol
    private let answersRepository: AnswersRepositoryProtocol
    private let gameStatusRepository: GameStatusRepositoryProtocol
    
    private let musicAPI = ASMusicAPI()
    private var cancellables = Set<AnyCancellable>()
    
    init(
        musicRepository: MusicRepositoryProtocol,
        playersRepository: PlayersRepositoryProtocol,
        answerRepository: AnswersRepositoryProtocol,
        gameStatusRepository: GameStatusRepositoryProtocol
    ) {
        self.musicRepository = musicRepository
        self.playersRepository = playersRepository
        self.answersRepository = answerRepository
        self.gameStatusRepository = gameStatusRepository
        bindGameStatus()
        bindAnswer()
        bindSubmissionStatus()
    }
    
    private func bindAnswer() {
        answersRepository.getAnswers()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newAnswers in
                self?.answers = newAnswers
            }
            .store(in: &cancellables)
    }
    
    private func bindGameStatus() {
        gameStatusRepository.getDueTime()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newDueTime in
                self?.dueTime = newDueTime
            }
            .store(in: &cancellables)
    }
    
    private func bindSubmissionStatus() {
        let playerPublisher = playersRepository.getPlayersCount()
        let answersPublisher = answersRepository.getAnswersCount()

        playerPublisher.combineLatest(answersPublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] playersCount, answersCount in
                let submitStatus = (submits: String(answersCount), total: String(playersCount))
                self?.submissionStatus = submitStatus
            }
            .store(in: &cancellables)
    }
    
    public func playMusic() {
        guard let data = musicData else { return }
        Task {
            await AudioHelper.shared.startPlaying(data)
        }
    }
    
    public func stopMusic() {
        Task {
            await AudioHelper.shared.stopPlaying()
        }
    }
    
    public func downloadArtwork(url: URL?) async -> Data? {
        guard let url else { return nil }
        do {
            let musicData = try await musicRepository.getMusicData(url: url)
            self.musicData = musicData
        }
        catch {
            return nil
        }
        return nil
    }
    
    public func handleSelectedSong(with music: Music) {
        selectedMusic = music
        beginPlaying()
    }
    public func submitMusic() async throws {
        guard let selectedMusic else { return }
        do {
            _ = try await answersRepository.submitMusic(answer: selectedMusic)
        } catch {
            throw error
        }
    }
 
    public func searchMusic(text: String) async throws {
        do {
            if text.isEmpty { return }
            searchList = try await musicAPI.search(for: text)
        } catch {
            throw error
        }
    }
    
    public func downloadMusic(url: URL) {
        Task { @MainActor in
            musicData = try await musicRepository.getMusicData(url: url)
        }
    }
    
    private func beginPlaying() {
        guard let url = selectedMusic?.previewUrl else { return }
        downloadMusic(url: url)
    }
    
    public func resetSearchList() {
        searchList = []
    }
    
    public func cancelSubscriptions() {
        cancellables.removeAll()
    }
}
