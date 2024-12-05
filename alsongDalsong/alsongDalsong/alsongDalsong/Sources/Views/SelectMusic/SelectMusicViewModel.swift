import ASEntity
import ASMusicKit
import ASRepositoryProtocol
import Combine
import Foundation

final class SelectMusicViewModel: ObservableObject, @unchecked Sendable {
    @Published private(set) var answers: [Answer] = []
    @Published private(set) var searchList: [Music] = []
    @Published private(set) var isSearching: Bool = false
    @Published private(set) var dueTime: Date?
    @Published private(set) var selectedMusic: Music?
    @Published private(set) var submissionStatus: (submits: String, total: String) = ("0", "0")

    @Published private(set) var musicData: Data? {
        didSet { isPlaying = true }
    }

    @Published var isPlaying: Bool = false {
        didSet { isPlaying ? playMusic() : stopMusic() }
    }
    
    private let musicRepository: MusicRepositoryProtocol
    private let playersRepository: PlayersRepositoryProtocol
    private let answersRepository: AnswersRepositoryProtocol
    private let gameStatusRepository: GameStatusRepositoryProtocol
    
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
    
    func playMusic() {
        guard let data = musicData else { return }
        Task {
            await AudioHelper.shared.startPlaying(data, option: .full)
        }
    }
    
    func stopMusic() {
        Task {
            await AudioHelper.shared.stopPlaying()
        }
    }
    
    func downloadArtwork(url: URL?) async -> Data? {
        guard let url else { return nil }
        return await musicRepository.getMusicData(url: url)
    }
    
    func handleSelectedSong(with music: Music) {
        selectedMusic = music
        beginPlaying()
    }
  
    func submitMusic() async throws {
        if let selectedMusic {
            do {
                _ = try await answersRepository.submitMusic(answer: selectedMusic)
            } catch {
                throw error
            }
        }
    }
 
    func searchMusic(text: String) async throws {
        do {
            if text.isEmpty { return }
            
            await updateIsSearching(with: true)
            
            let startTime = Date()
            let searchList = try await ASMusicAPI.search(for: text)
            let finishTime = Date()
            let elapsed = finishTime.timeIntervalSince(startTime)
            print("elapsed:\(elapsed)")
            await updateSearchList(with: searchList)
            await updateIsSearching(with: false)
        } catch {
            throw error
        }
    }
    
    func randomMusic() async throws {
        do {
            selectedMusic = try await ASMusicAPI.randomSong(from: "pl.u-aZb00o7uPlzMZzr")
        } catch {
            throw error
        }
    }
    
    func downloadMusic(url: URL) {
        Task {
            guard let musicData = await musicRepository.getMusicData(url: url) else {
                return
            }
            await updateMusicData(with: musicData)
        }
    }
    
    private func beginPlaying() {
        guard let url = selectedMusic?.previewUrl else { return }
        downloadMusic(url: url)
    }
    
    @MainActor
    func resetSearchList() {
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
    
    @MainActor
    private func updateIsSearching(with isSearching: Bool) {
        self.isSearching = isSearching
    }
    
    func cancelSubscriptions() {
        cancellables.removeAll()
    }
}
