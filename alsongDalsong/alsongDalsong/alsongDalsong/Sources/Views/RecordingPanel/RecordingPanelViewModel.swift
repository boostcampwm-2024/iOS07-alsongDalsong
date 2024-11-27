import Combine
import Foundation

final class RecordingPanelViewModel: @unchecked Sendable {
    @Published var recordedData: Data?
    @Published public private(set) var recorderAmplitude: Float = 0.0
    @Published public private(set) var buttonState: AudioButtonState = .idle

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
            if buttonState == .recording { return }
            if buttonState == .playing { stopPlaying() }
            buttonState = .recording
            let data = await AudioHelper.shared.startRecording()
            recordedData = data
            buttonState = .idle
        }
    }

    @MainActor
    func togglePlayPause() {
        if buttonState == .recording { return }
        if recordedData != nil {
            Task { [weak self] in
                if await AudioHelper.shared.isPlaying() {
                    self?.buttonState = .idle
                    await AudioHelper.shared.stopPlaying()
                } else {
                    self?.buttonState = .playing
                    await AudioHelper.shared.startPlaying(file: self?.recordedData) {
                        self?.buttonState = .idle
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
