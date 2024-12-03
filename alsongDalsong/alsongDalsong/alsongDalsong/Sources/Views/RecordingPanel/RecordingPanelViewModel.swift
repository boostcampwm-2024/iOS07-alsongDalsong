import Combine
import Foundation

final class RecordingPanelViewModel: @unchecked Sendable {
    let sampleCount: Int = 48
    @Published var recordedData: Data?
    @Published private(set) var recorderAmplitude: Float = 0.0
    @Published private(set) var buttonState: AudioButtonState = .idle
    @Published private(set) var playIndex: Int?

    private var cancellables = Set<AnyCancellable>()

    init() {
        bindAudioHelper()
    }

    func configureAudioHelper() async {
        await AudioHelper.shared
            .playType(.full)
            .isConcurrent(false)
    }

    @MainActor
    func startRecording() {
        Task {
            if buttonState == .recording { return }
            if buttonState == .playing { stopPlaying() }
            await AudioHelper.shared.startRecording()
        }
    }

    private func updateButtonState(_ state: AudioButtonState) {
        buttonState = state
    }

    @MainActor
    func togglePlayPause() {
        guard recordedData != nil else { return }

        Task { [weak self] in
            await self?.configureAudioHelper()
            if self?.buttonState == .playing {
                await AudioHelper.shared.stopPlaying()
                return
            }
            if self?.buttonState == .idle {
                await AudioHelper.shared.startPlaying(self?.recordedData, sourceType: .recorded, option: .full, needsWaveUpdate: true)
                return
            }
        }
    }

    @MainActor
    private func stopPlaying() {
        Task {
            await AudioHelper.shared.stopPlaying()
        }
    }

    private func bindAudioHelper() {
        Task {
            await AudioHelper.shared.amplitudePublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] newAmplitude in
                    guard let self = self else { return }
                    self.recorderAmplitude = newAmplitude
                }
                .store(in: &self.cancellables)

            await AudioHelper.shared.playerStatePublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] source, isPlaying in
                    if source == .recorded {
                        self?.updateButtonState(isPlaying ? .playing : .idle)
                        return
                    }
                    if isPlaying {
                        self?.updateButtonState(.idle)
                        return
                    }
                }
                .store(in: &self.cancellables)

            await AudioHelper.shared.waveformUpdatePublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] index in
                    guard let self else { return }
                    if index > self.sampleCount - 1 || index < 0 { return }
                    self.playIndex = index
                }
                .store(in: &self.cancellables)

            await AudioHelper.shared.recorderStatePublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] isRecording in
                    self?.updateButtonState(isRecording ? .recording : .idle)
                }
                .store(in: &self.cancellables)

            await AudioHelper.shared.recorderDataPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] data in
                    self?.recordedData = data
                }
                .store(in: &self.cancellables)
        }
    }
}
