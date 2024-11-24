import Foundation
import ASEntity
import Combine
import ASRepository
final class MusicPanelViewModel {
    @Published var music: Music?
    @Published var artwork: Data?
    @Published var preview: Data?
    private let musicRepository: MusicRepositoryProtocol?
    private var cancellables = Set<AnyCancellable>()

    init(music: Music?, musicRepository: MusicRepositoryProtocol?) {
        self.music = music
        self.musicRepository = musicRepository
        getPreviewData()
        getArtworkData()
    }

    private func getPreviewData() {
        guard let previewUrl = music?.previewUrl else { return }
        musicRepository?.getMusicData(url: previewUrl)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                    case .finished:
                        break
                    case let .failure(error):
                        print(error.localizedDescription)
                }
            } receiveValue: { [weak self] preview in
                self?.preview = preview
            }
            .store(in: &cancellables)
    }

    private func getArtworkData() {
        guard let artworkUrl = music?.artworkUrl else { return }
        musicRepository?.getMusicData(url: artworkUrl)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                    case .finished:
                        break
                    case let .failure(error):
                        print(error.localizedDescription)
                }
            } receiveValue: { [weak self] artwork in
                self?.artwork = artwork
            }
            .store(in: &cancellables)
    }

    @MainActor
    func togglePlayPause(isPlaying: Bool = true) {
        Task {
            isPlaying ?
                await AudioHelper.shared.stopPlaying() :
                await AudioHelper.shared.startPlaying(file: preview)
        }
    }
}
