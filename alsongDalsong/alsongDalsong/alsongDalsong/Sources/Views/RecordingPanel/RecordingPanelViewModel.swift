import Combine
import Foundation

final class RecordingPanelViewModel: @unchecked Sendable {
    @Published var recordedData: Data?
    @Published public private(set) var recorderAmplitude: Float = 0.0
    private var cancellables = Set<AnyCancellable>()
    
    init(){
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
    func togglePlayPause(isPlaying: Bool = true) {
        Task {
            isPlaying ?
                await AudioHelper.shared.stopPlaying() :
                await AudioHelper.shared.startPlaying(file: recordedData)
        }
    }
}
