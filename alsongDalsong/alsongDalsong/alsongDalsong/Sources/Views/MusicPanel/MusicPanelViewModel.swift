import ASEntity
import ASRepository
import Combine
import Foundation

final class MusicPanelViewModel: @unchecked Sendable {
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
        bindAudioHelper()
    }

    private func bindAudioHelper() {
        Task {
            await AudioHelper.shared.playerStatePublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] source, isPlaying in
                    if source == .imported {
                        self?.updateButtonState(isPlaying ? .playing : .idle)
                        return
                    }
                    if source == .recorded, isPlaying {
                        self?.updateButtonState(.idle)
                        return
                    }
                }
                .store(in: &cancellables)
            await AudioHelper.shared.recorderStatePublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] isRecording in
                    if isRecording {
                        self?.updateButtonState(.idle)
                    }
                }
                .store(in: &cancellables)
        }
    }

    func configureAudioHelper() async {
        await AudioHelper.shared
            .playType(.full)
            .isConcurrent(false)
    }

    @MainActor
    func togglePlayPause() {
        guard preview != nil else { return }
        Task { [weak self] in
            await self?.configureAudioHelper()
            if self?.buttonState == .playing {
                await AudioHelper.shared.stopPlaying()
                return
            }
            if self?.buttonState == .idle {
                await AudioHelper.shared.startPlaying(self?.preview, sourceType: .imported)
                return
            }
        }
    }

    private func updateButtonState(_ state: AudioButtonState) {
        buttonState = state
    }

    private func getPreviewData() {
        guard let previewUrl = music?.previewUrl else { return }
        Task { @MainActor in
            preview = await musicRepository?.getMusicData(url: previewUrl)
        }
    }

    private func getArtworkData() {
        guard let artworkUrl = music?.artworkUrl else { return }
        Task { @MainActor in
            artwork = await musicRepository?.getMusicData(url: artworkUrl)
        }
    }
}
