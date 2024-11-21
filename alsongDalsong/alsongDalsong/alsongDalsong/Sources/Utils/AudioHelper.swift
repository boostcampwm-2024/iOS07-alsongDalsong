import ASAudioKit
import Combine
import Foundation

extension AnyPublisher: @unchecked @retroactive Sendable {}

actor AudioHelper {
    static let shared = AudioHelper()
    private var recorder: ASAudioRecorder?
    private var player: ASAudioPlayer?
    private var timer: Timer?
    private let amplitudeSubject = PassthroughSubject<Float, Never>()
    private init() {}

    func amplitudePubisher() -> AnyPublisher<Float, Never> {
        return amplitudeSubject.eraseToAnyPublisher()
    }

    func isRecording() async -> Bool {
        guard let recorder else { return false }
        return await recorder.isRecording()
    }

    func isPlaying() async -> Bool {
        guard let player else { return false }
        return await player.isPlaying()
    }

    func startRecording() async -> Data? {
        makeRecorder()
        let tempURL = makeURL()
        await recorder?.startRecording(url: tempURL)
        visualize()
        return await withCheckedContinuation { continuation in
            DispatchQueue.main.asyncAfter(deadline: .now() + 6) { [weak self] in
                Task {
                    let recordedData = await self?.stopRecording()
                    await self?.removeTimer()
                    continuation.resume(returning: recordedData)
                }
            }
        }
    }

    private func removeTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func visualize() {
        Task { [weak self] in
            guard let self else { return }
            await self.setTimer()
        }
    }

    private func setTimer() {
        timer = Timer(timeInterval: 0.08, repeats: true) { [weak self] _ in
            Task {
                print("calculate amplitude")
                await self?.calculateRecorderAmplitude()
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    private func calculateRecorderAmplitude() async {
        await recorder?.updateMeters()
        guard let averagePower = await recorder?.getAveragePower() else { return }
        let newAmplitude = 1.1 * pow(10.0, averagePower / 20.0)
        let clampedAmplitude = min(max(newAmplitude, 0), 1)
        print("clampedAmplitude")
        amplitudeSubject.send(clampedAmplitude)
    }

    func startPlaying(file: Data?, playType: PlayType = .full) async {
        guard let file else { return }
        makePlayer()
        await player?.setOnPlaybackFinished { [weak self] in
            await self?.stopPlaying()
        }
        await player?.startPlaying(data: file, option: playType)
    }

    func stopPlaying() async {
        await player?.stopPlaying()
    }

    private func stopRecording() async -> Data? {
        await recorder?.stopRecording()
    }

    private func makeRecorder() {
        recorder = ASAudioRecorder()
    }

    private func makePlayer() {
        player = ASAudioPlayer()
    }

    private func makeURL() -> URL {
        let tempCacheDirectory = FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask).first!
            .appendingPathComponent("tempCache")
        createCacheDirectory(with: tempCacheDirectory)
        let key = UUID()
        return tempCacheDirectory
            .appendingPathComponent("\(key)")
    }

    private func createCacheDirectory(with directory: URL) {
        if !FileManager.default.fileExists(atPath: directory.path) {
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        }
    }
}
