import ASEntity
import ASMusicKit
import ASRepository
import Combine
import Foundation

final class SelectMusicViewModel: ObservableObject, @unchecked Sendable {
    @Published public private(set) var answers: [Answer] = []
    @Published public private(set) var searchList: [ASSong] = []
    @Published public private(set) var dueTime: Date?
    @Published public private(set) var selectedSong: ASSong = .init(id: "12345")
    @Published public private(set) var musicData: Data? {
        didSet {
            isPlaying = true
        }
    }

    @Published public var isPlaying: Bool = false {
        didSet {
            isPlaying ? playingMusic() : stopMusic()
        }
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
    
    func downloadMusic(url: URL?) {
        guard let url else { return }
        musicRepository.getMusicData(url: url)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] data in
                self?.musicData = data
            }
            .store(in: &cancellable)
    }
    
    func playingMusic() {
        guard let data = musicData else { return }
        Task {
            await AudioHelper.shared.startPlaying(file: data)
        }
    }
    
    func stopMusic() {
        Task {
            await AudioHelper.shared.stopPlaying()
        }
    }
    
    func handleSelectedSong(song: ASSong) {
        selectedSong = song
        beginPlaying()
    }
    
    func beginPlaying() {
        downloadMusic(url: selectedSong.previewURL)
    }
    
    func submitMusic() async throws {
        let answer = ASEntity.Music(
            title: selectedSong.title,
            artist: selectedSong.artistName,
            artworkUrl: selectedSong.artwork?.url(
                width: 300,
                height: 300
            ),
            previewUrl: selectedSong.previewURL,
            artworkBackgroundColor: selectedSong.artwork?.backgroundColor?.toHex()
        )
        let response = try await answerRepository.submitMusic(answer: answer)
    }
 
    @MainActor
    func searchMusic(text: String) {
        Task {
            if text.isEmpty { return }
            searchList = await musicAPI.search(for: text)
        }
    }
}
