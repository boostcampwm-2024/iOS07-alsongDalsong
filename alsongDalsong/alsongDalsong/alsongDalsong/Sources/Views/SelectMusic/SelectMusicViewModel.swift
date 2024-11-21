import ASMusicKit
import ASRepository
import Combine
import Foundation
import MusicKit

final class SelectMusicViewModel: ObservableObject {
    @Published var musicData: Data? {
        didSet {
            playingMusic()
        }
    }

    var cancellable = Set<AnyCancellable>()
    let musicRepository: MusicRepositoryProtocol
    let musicAPI = ASMusicAPI()
    
    init(musicRepository: MusicRepositoryProtocol) {
        self.musicRepository = musicRepository
    }
    
    @Published var searchList: [ASSong] = []
    @Published var selectedSong: ASSong = .init(id: "12345", title: "선택된 곡 없음", artistName: "아티스트", artwork: nil, previewURL: URL(string: ""))
    
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
    
    func handleSelectedSong(song: ASSong) {
        selectedSong = song
        beginPlaying(song: song)
    }
    
    func beginPlaying(song: ASSong) {
        downloadMusic(url: song.previewURL)
    }
    
    @MainActor
    func searchMusic(text: String) {
        Task {
            searchList = await musicAPI.search(for: text)
        }
    }
}
