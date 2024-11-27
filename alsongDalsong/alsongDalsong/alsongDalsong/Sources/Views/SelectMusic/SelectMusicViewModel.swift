import ASEntity
import ASMusicKit
import ASRepository
import Combine
import Foundation

final class SelectMusicViewModel: ObservableObject, @unchecked Sendable {
    @Published public private(set) var answers: [Answer] = []
    @Published public private(set) var searchList: [Music] = []
    @Published public private(set) var dueTime: Date?
    @Published public private(set) var selectedMusic: Music?
    @Published public private(set) var musicData: Data? {
        didSet { isPlaying = true }
    }

    @Published public var isPlaying: Bool = false {
        didSet { isPlaying ? playingMusic() : stopMusic() }
    }
    
    private let musicRepository: MusicRepositoryProtocol
    private let answerRepository: AnswersRepositoryProtocol
    private let gameStatusRepository: GameStatusRepositoryProtocol
    
    private let musicAPI = ASMusicAPI()
    private var cancellable = Set<AnyCancellable>()
    
    init(
        musicRepository: MusicRepositoryProtocol,
        answerRepository: AnswersRepositoryProtocol,
        gameStatusRepository: GameStatusRepositoryProtocol
    ) {
        self.musicRepository = musicRepository
        self.answerRepository = answerRepository
        self.gameStatusRepository = gameStatusRepository
        bindGameStatus()
        bindAnswer()
    }
    
    private func bindAnswer() {
        answerRepository.getAnswers()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newAnswers in
                self?.answers = newAnswers
            }
            .store(in: &cancellable)
    }
    
    private func bindGameStatus() {
        gameStatusRepository.getDueTime()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newDueTime in
                self?.dueTime = newDueTime
            }
            .store(in: &cancellable)
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
    public func handleSelectedSong(with music: Music) {
        selectedMusic = music
        beginPlaying()
    }
    
    public func submitMusic() async throws {
        guard let selectedMusic else { return }
        _ = try await answerRepository.submitMusic(answer: selectedMusic)
    }
 
    @MainActor
    public func searchMusic(text: String) {
        Task {
            if text.isEmpty { return }
            searchList = await musicAPI.search(for: text)
        }
    }
    
    @MainActor
    private func downloadMusic(url: URL) {
        Task {
            musicData = await musicRepository.getMusicData(url: url)
        }
    }
    
    @MainActor
    private func beginPlaying() {
        guard let url = selectedMusic?.previewUrl else { return }
        downloadMusic(url: url)
    }
}
