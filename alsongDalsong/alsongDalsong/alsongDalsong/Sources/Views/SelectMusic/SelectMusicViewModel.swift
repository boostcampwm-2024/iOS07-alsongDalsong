import ASEntity
import ASMusicKit
import ASRepositoryProtocol
import Combine
import Foundation

final class SelectMusicViewModel: ObservableObject, @unchecked Sendable {
    @Published public private(set) var answers: [Answer] = []
    @Published public private(set) var searchList: [Music] = []
    @Published public private(set) var isSearching: Bool = false
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
            await AudioHelper.shared.startPlaying(data, option: .full)
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
            return try await musicRepository.getMusicData(url: url)
        } catch {
            return nil
        }
    }
    
    public func handleSelectedSong(with music: Music) {
        selectedMusic = music
        beginPlaying()
    }

    public func submitMusic() async throws {
        if let selectedMusic {
            do {
                _ = try await answersRepository.submitMusic(answer: selectedMusic)
            } catch {
                throw error
            }
        }
    }
 
    public func searchMusic(text: String) async throws {
        do {
            if text.isEmpty { return }
            isSearching = true
            let searchList = try await musicAPI.search(for: text)
            await updateSearchList(with: searchList)
            isSearching = false
        } catch {
            throw error
        }
    }
    
    public func randomMusic() async throws {
        do {
            selectedMusic = try await musicAPI.randomSong(from: "pl.u-aZb00o7uPlzMZzr")
        } catch {
            throw error
        }
    }
    
    public func downloadMusic(url: URL) {
        Task {
            guard let musicData = try await musicRepository.getMusicData(url: url) else {
                return
            }
            await updateMusicData(with: musicData)
        }
    }
    
    private func beginPlaying() {
        guard let url = selectedMusic?.previewUrl else { return }
        downloadMusic(url: url)
    }
    
    public func resetSearchList() {
        searchList = []
    }
    
    @MainActor
    private func updateMusicData(with musicData: Data) {
        self.musicData = musicData
    }
    
    @MainActor
    private func updateSearchList(with searchList: [Music]) {
        self.searchList = searchList
    }
    
    public func cancelSubscriptions() {
        cancellables.removeAll()
    }
}
