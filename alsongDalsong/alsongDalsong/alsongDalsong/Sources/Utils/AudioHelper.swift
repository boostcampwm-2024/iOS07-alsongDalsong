import ASAudioKit
import ASLogKit
import Combine
import Foundation

extension AnyPublisher: @unchecked @retroactive Sendable {}
extension PassthroughSubject: @unchecked @retroactive Sendable {}
extension AudioHelper {
    enum FileSource {
        case imported
        case recorded
    }
}

actor AudioHelper {
    // MARK: - Private properties

    static let shared = AudioHelper()
    private var recorder: ASAudioRecorder?
    private var player: ASAudioPlayer?
    private var source: FileSource = .imported
    private var playType: PlayType = .full
    private var isConcurrent: Bool = false
    private var timer: Timer?

    // MARK: - Publishers

    private let amplitudeSubject = PassthroughSubject<Float, Never>()
    private let playerStateSubject = PassthroughSubject<(FileSource, Bool), Never>()
    private let recorderStateSubject = PassthroughSubject<Bool, Never>()
    private let recorderDataSubject = PassthroughSubject<Data, Never>()
    var amplitudePublisher: AnyPublisher<Float, Never> { amplitudeSubject.eraseToAnyPublisher() }

    var playerStatePublisher: AnyPublisher<(FileSource, Bool), Never> {
        playerStateSubject.eraseToAnyPublisher()
    }

    var recorderStatePublisher: AnyPublisher<Bool, Never> {
        recorderStateSubject.eraseToAnyPublisher()
    }

    var recorderDataPublisher: AnyPublisher<Data, Never> {
        recorderDataSubject.eraseToAnyPublisher()
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

    private func removeTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Play Audio

extension AudioHelper {
    /// 여러 조건을 적용해 오디오를 재생하는 함수
    /// - Parameters:
    ///   - file: 재생할 오디오 데이터
    ///   - source: 녹음 파일/url에서 가져온 파일
    ///   - playType: 전체 또는 부분 재생
    ///   - allowsConcurrent: 녹음과 동시에 재생
    func startPlaying(_ file: Data?, sourceType type: FileSource = .imported) async {
        guard await checkRecorderState(), await checkPlayerState() else { return }
        guard let file else { return }

        sourceType(type)
        makePlayer()
        await player?.setOnPlaybackFinished { [weak self] in
            await self?.stopPlaying()
        }
        sendDataThrough(playerStateSubject, (source, true))
        await player?.startPlaying(data: file, option: playType)
    }

    func stopPlaying() async {
        await player?.stopPlaying()
        player = nil
        sendDataThrough(playerStateSubject, (source, false))
    }

    private func makePlayer() {
        player = ASAudioPlayer()
    }

    private func checkPlayerState() async -> Bool {
        if await isPlaying() {
            await player?.stopPlaying()
            sendDataThrough(playerStateSubject, (source, false))
        }
        return true
    }
}

// MARK: - Record Audio

extension AudioHelper {
    func startRecording() async {
        guard await checkRecorderState(), await checkPlayerState() else { return }

        makeRecorder()
        let tempURL = makeURL()
        recorderStateSubject.send(true)
        await recorder?.startRecording(url: tempURL)
        visualize()
        do {
            try await Task.sleep(nanoseconds: 6 * 1_000_000_000)
            let recordedData = await stopRecording()
            sendDataThrough(recorderDataSubject, recordedData ?? Data())
            removeTimer()
        } catch { Logger.error(error.localizedDescription) }
    }

    private func stopRecording() async -> Data? {
        let recordedData = await recorder?.stopRecording()
        recorderStateSubject.send(false)
        recorder = nil
        return recordedData
    }

    private func checkRecorderState() async -> Bool {
        if await isRecording(), !isConcurrent { return false }
        return true
    }

    private func makeRecorder() {
        recorder = ASAudioRecorder()
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

// MARK: - Configure AudioHelper

extension AudioHelper {
    @discardableResult
    private func sourceType(_ type: FileSource) -> Self {
        source = type
        return self
    }

    @discardableResult
    func playType(_ type: PlayType) -> Self {
        playType = type
        return self
    }

    @discardableResult
    func isConcurrent(_ isTrue: Bool) -> Self {
        isConcurrent = isTrue
        return self
    }
}

// MARK: - Data binding

extension AudioHelper {
    private func sendDataThrough<T>(_ subject: PassthroughSubject<T, Never>, _ data: T) {
        subject.send(data)
    }
}

// MARK: - Audio Visualize

extension AudioHelper {
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
}
