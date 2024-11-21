import Foundation
import MusicKit
import ASMusicKit
import ASRepository
import ASNetworkKit
import Combine
import ASCacheKit
import ASAudioKit
import ASMusicKit

final class SelectMusicViewModel: ObservableObject {
    @Published var musicData: Data? {
        didSet {
            playingMusic()
        }
    }
    var cancellable = Set<AnyCancellable>()
    let musicRepository = MusicRepository(firebaseManager: ASFirebaseManager(), networkManager: ASNetworkManager(cacheManager: ASCacheManager()))
    let audioPlayer = ASAudioPlayer()
    let musicAPI = ASMusicAPI()
    
    @Published var searchList: [ASSong] = []
    @Published var selectedSong: ASSong = ASSong(id: "12345", title: "선택된 곡 없음", artistName: "아티스트", artwork: URL(string: ""), previewURL: URL(string: ""))
    
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
        audioPlayer.startPlaying(data: data, option: .full)
    }
    
    func handleSelectedSong(song: ASSong) {
        self.selectedSong = song
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
