import ASAudioKit
import Foundation

actor AudioHelper {
    static let shared = AudioHelper()
    private var recorder: ASAudioRecorder?
    private var player: ASAudioPlayer?

    private init() {}

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
        return await withCheckedContinuation { continuation in
            DispatchQueue.main.asyncAfter(deadline: .now() + 6) { [weak self] in
                Task {
                    let recordedData = await self?.stopRecording()
                    continuation.resume(returning: recordedData)
                }
            }
        }
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
