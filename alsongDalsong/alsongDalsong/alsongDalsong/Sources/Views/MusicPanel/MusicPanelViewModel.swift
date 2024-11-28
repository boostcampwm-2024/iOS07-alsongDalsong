import Foundation
import ASEntity
import Combine
import ASRepository

final class MusicPanelViewModel: @unchecked Sendable {
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
        Task {
            preview = await musicRepository?.getMusicData(url: previewUrl)
        }
    }

    private func getArtworkData() {
        guard let artworkUrl = music?.artworkUrl else { return }
        Task {
            artwork = await musicRepository?.getMusicData(url: artworkUrl)
        }
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
