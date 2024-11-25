import ASEntity
import ASMusicKit
import ASRepository
import Combine
import Foundation
import MusicKit

final class SelectMusicViewModel: ObservableObject {
    @Published var musicData: Data? {
        didSet {
            isPlaying = true
        }
    }

    var cancellable = Set<AnyCancellable>()
    let musicRepository: MusicRepositoryProtocol
    let answerRepository: AnswersRepositoryProtocol
    let musicAPI = ASMusicAPI()
    
    init(musicRepository: MusicRepositoryProtocol, answerRepository: AnswersRepositoryProtocol) {
        self.musicRepository = musicRepository
        self.answerRepository = answerRepository
    }
    
    @Published var searchList: [ASSong] = []
    @Published var selectedSong: ASSong = .init(
        id: "12345",
        title: "선택된 곡 없음",
        artistName: "아티스트",
        artwork: nil,
        previewURL: URL(string: "")
    )
    @Published var isPlaying: Bool = false {
        didSet {
            if isPlaying {
                playingMusic()
            } else {
                stopMusic()
            }
        }
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
    
    @MainActor
    func submitMusic() {
        guard let artworkBackgroundColor = selectedSong.artwork?.backgroundColor?.toHex() else { return }
        let answer = ASEntity.Music(title: selectedSong.title, artist: selectedSong.artistName, artworkUrl: selectedSong.artwork?.url(width: 300, height: 300), previewUrl: selectedSong.previewURL, artworkBackgroundColor: artworkBackgroundColor)
        Task {
            do {
                let response = try await answerRepository.submitMusic(answer: answer)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
 
    @MainActor
    func searchMusic(text: String) {
        Task {
            searchList = await musicAPI.search(for: text)
        }
    }
}
