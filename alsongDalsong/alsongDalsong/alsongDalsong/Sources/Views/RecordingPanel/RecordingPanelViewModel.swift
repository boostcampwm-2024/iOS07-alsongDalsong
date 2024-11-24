import Combine
import Foundation

final class RecordingPanelViewModel: @unchecked Sendable {
    @Published var recordedData: Data?
    @Published public private(set) var recorderAmplitude: Float = 0.0
    @Published public private(set) var isPlaying: Bool = false
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
            let data = await AudioHelper.shared.startRecording()
            recordedData = data
        }
    }

    @MainActor
    func togglePlayPause() {
        if recordedData != nil {
            Task { [weak self] in
                if await AudioHelper.shared.isPlaying() {
                    self?.isPlaying = false
                    await AudioHelper.shared.stopPlaying()
                } else {
                    self?.isPlaying = true
                    await AudioHelper.shared.startPlaying(file: self?.recordedData)
                }
            }
        }
    }
}
