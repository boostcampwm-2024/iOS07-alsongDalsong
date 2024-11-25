import Combine
import Foundation

final class RecordingPanelViewModel: @unchecked Sendable {
    @Published var recordedData: Data?
    @Published public private(set) var recorderAmplitude: Float = 0.0
    @Published public private(set) var panelState: PanelState = .idle

    private var cancellables = Set<AnyCancellable>()

    init() {
        bindAmplitudeUpdates()
    }

    private func bindAmplitudeUpdates() {
        Task {
            await AudioHelper.shared.amplitudePublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] newAmplitude in
                    guard let self = self else { return }
                    self.recorderAmplitude = newAmplitude
                }
                .store(in: &self.cancellables)
        }
    }

    @MainActor
    func startRecording() {
        Task {
            if panelState == .recording { return }
            if panelState == .playing { stopPlaying() }
            panelState = .recording
            let data = await AudioHelper.shared.startRecording()
            recordedData = data
            panelState = .idle
        }
    }

    @MainActor
    func togglePlayPause() {
        if panelState == .recording { return }
        if recordedData != nil {
            Task { [weak self] in
                if await AudioHelper.shared.isPlaying() {
                    self?.panelState = .idle
                    await AudioHelper.shared.stopPlaying()
                } else {
                    self?.panelState = .playing
                    await AudioHelper.shared.startPlaying(file: self?.recordedData) {
                        self?.panelState = .idle
                    }
                }
            }
        }
    }

    @MainActor
    private func stopPlaying() {
        Task {
            await AudioHelper.shared.stopPlaying()
        }
    }
}
