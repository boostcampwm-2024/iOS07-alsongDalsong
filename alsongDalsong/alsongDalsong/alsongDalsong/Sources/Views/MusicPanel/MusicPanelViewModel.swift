import ASEntity
import ASRepository
import Combine
import Foundation

final class MusicPanelViewModel {
    @Published var music: Music?
    @Published var artwork: Data?
    @Published var preview: Data?
    @Published public private(set) var buttonState: AudioButtonState = .idle
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
    func togglePlayPause() {
        if preview != nil {
            Task { [weak self] in
                if await AudioHelper.shared.isPlaying() {
                    self?.buttonState = .idle
                    await AudioHelper.shared.stopPlaying()
                } else {
                    self?.buttonState = .playing
                    await AudioHelper.shared.startPlaying(file: self?.preview) {
                        self?.buttonState = .idle
                    }
                }
            }
        }
    }
}
