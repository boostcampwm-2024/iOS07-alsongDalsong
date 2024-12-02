import ASEntity
import ASRepositoryProtocol
import Combine
import Foundation

final class MusicPanelViewModel: @unchecked Sendable {
    @Published var type: MusicPanelType
    @Published var music: Music?
    @Published var artwork: Data?
    @Published var preview: Data?
    @Published public private(set) var buttonState: AudioButtonState = .idle
    private let musicRepository: MusicRepositoryProtocol?
    private var cancellables = Set<AnyCancellable>()

    init(
        music: Music?,
        type: MusicPanelType = .large,
        musicRepository: MusicRepositoryProtocol?
    ) {
        self.music = music
        self.type = type
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
                    switch source {
                        case let .imported(panelType):
                            self?.updateButtonState(type: panelType, isPlaying ? .playing : .idle)
                        default: if isPlaying {
                                self?.updateButtonState(type: .compact, .idle)
                                self?.updateButtonState(type: .large, .idle)
                            }
                    }
                }
                .store(in: &cancellables)
            await AudioHelper.shared.recorderStatePublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] isRecording in
                    if isRecording {
                        self?.updateButtonState(type: .compact, .idle)
                        self?.updateButtonState(type: .large, .idle)
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
    func togglePlayPause(_ type: MusicPanelType) {
        guard preview != nil else { return }
        Task { [weak self] in
            guard let self else { return }
            await self.configureAudioHelper()
            if buttonState == .playing {
                await AudioHelper.shared.stopPlaying()
                return
            }
            if buttonState == .idle {
                await AudioHelper.shared.startPlaying(
                    self.preview,
                    sourceType: .imported(type)
                )
                return
            }
        }
    }

    private func updateButtonState(type: MusicPanelType, _ state: AudioButtonState) {
        if self.type == type {
            buttonState = state
        }

    }

    private func getPreviewData() {
        guard let previewUrl = music?.previewUrl else { return }
        Task { @MainActor in
            preview = try await musicRepository?.getMusicData(url: previewUrl)
        }
    }

    private func getArtworkData() {
        guard let artworkUrl = music?.artworkUrl else { return }
        Task { @MainActor in
            artwork = try await musicRepository?.getMusicData(url: artworkUrl)
        }
    }
}
