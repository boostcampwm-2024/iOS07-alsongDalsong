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
    var amplitudePublisher: AnyPublisher<Float, Never> {
        return amplitudeSubject.eraseToAnyPublisher()
    }

    private init() {}

    func isRecording() async -> Bool {
        guard let recorder else { return false }
        return await recorder.isRecording()
    }

    func isPlaying() async -> Bool {
        guard let player else { return false }
        return await player.isPlaying()
    }

    func startRecording(allowsConcurrent: Bool = false) async -> Data? {
        if await isPlaying(), !allowsConcurrent { return nil }
        else { await player?.stopPlaying() }
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
        timer = Timer(timeInterval: 0.125, repeats: true) { [weak self] _ in
            Task {
                await self?.calculateRecorderAmplitude()
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func calculateRecorderAmplitude() async {
        await recorder?.updateMeters()
        guard let averagePower = await recorder?.getAveragePower() else { return }
        let newAmplitude = 1.8 * pow(10.0, averagePower / 20.0)
        let clampedAmplitude = min(max(newAmplitude, 0), 1)
        amplitudeSubject.send(clampedAmplitude)
    }

    func startPlaying(
        file: Data?,
        playType: PlayType = .full,
        allowsConcurrent: Bool = false,
        didPlayingFinshied: (@MainActor () -> Void)? = nil
    ) async {
        if await isRecording(), !allowsConcurrent { return }
        else { await recorder?.stopRecording() }
        guard let file else { return }
        if let player = player, await player.isPlaying() { await stopPlaying() }
        makePlayer()
        await player?.setOnPlaybackFinished { [weak self] in
            await self?.stopPlaying()
            await didPlayingFinshied?()
        }
        await player?.startPlaying(data: file, option: playType)
    }

    func stopPlaying() async {
        await player?.stopPlaying()
        player = nil
    }

    private func stopRecording() async -> Data? {
        let recordedData = await recorder?.stopRecording()
        recorder = nil
        return recordedData
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
