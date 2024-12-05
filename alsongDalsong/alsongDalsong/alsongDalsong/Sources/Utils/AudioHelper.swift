import ASAudioKit
import ASLogKit
import Combine
import Foundation

extension AnyPublisher: @unchecked @retroactive Sendable {}
extension PassthroughSubject: @unchecked @retroactive Sendable {}

actor AudioHelper {
    // MARK: - Private properties

    static let shared = AudioHelper()
    private var recorder: ASAudioRecorder?
    private var player: ASAudioPlayer?
    private var source: FileSource = .imported(.large)
    private var playType: PlayType = .full
    private var isConcurrent: Bool = false
    private var cancellable: AnyCancellable?

    // MARK: - Publishers

    private let amplitudeSubject = PassthroughSubject<Float, Never>()
    private let playerStateSubject = PassthroughSubject<(FileSource, Bool), Never>()
    private let waveformUpdateSubject = PassthroughSubject<Int, Never>()
    private let recorderStateSubject = PassthroughSubject<Bool, Never>()
    private let recorderDataSubject = PassthroughSubject<Data, Never>()
    var amplitudePublisher: AnyPublisher<Float, Never> { amplitudeSubject.eraseToAnyPublisher() }

    var playerStatePublisher: AnyPublisher<(FileSource, Bool), Never> {
        playerStateSubject.eraseToAnyPublisher()
    }

    var waveformUpdatePublisher: AnyPublisher<Int, Never> {
        waveformUpdateSubject.eraseToAnyPublisher()
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

    private func removePlayer() async {
        player = nil
    }

    private func removeRecorder() {
        recorder = nil
    }

    private func removeTimer() {
        cancellable?.cancel()
        cancellable = nil
    }

    func analyze(with data: Data) async -> [CGFloat] {
        do {
            Logger.debug("파형분석 시작")
            let columns = try await ASAudioAnalyzer.analyze(data: data, samplesCount: 24)
            Logger.debug("파형분석 완료")
            Logger.debug(columns)
            return columns
        } catch {
            return []
        }
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
    func startPlaying(_ file: Data?,
                      sourceType type: FileSource = .imported(.large),
                      option: PlayType = .full,
                      needsWaveUpdate: Bool = false) async
    {
        guard await checkRecorderState(), await checkPlayerState() else { return }
        guard let file else { return }

        setPlayOption(option: option)
        sourceType(type)
        makePlayer()
        await player?.setOnPlaybackFinished { [weak self] in
            await self?.stopPlaying()
        }
        sendDataThrough(playerStateSubject, (source, true))
        if needsWaveUpdate {
            updatePlayIndex()
        }
        await play(file: file, option: option)
    }

    func play(file: Data, option: PlayType) async {
        switch option {
            case .full: await player?.startPlaying(data: file)
            case let .partial(time):
                await player?.startPlaying(data: file)
                do {
                    try await Task.sleep(nanoseconds: UInt64(time * 1_000_000_000))
                    await stopPlaying()
                } catch { Logger.error(error.localizedDescription) }
            @unknown default: break
        }
    }

    func stopPlaying() async {
        await player?.stopPlaying()
        await removePlayer()
        sendDataThrough(playerStateSubject, (source, false))
        removeTimer()
    }

    private func updatePlayIndex() {
        cancellable = Timer.publish(every: 0.125, on: .main, in: .common)
            .autoconnect()
            .scan(0) { count, _ in
                count + 1
            }
            .sink { [weak self] value in
                guard let self else { return }
                Task {
                    await self.sendDataThrough(self.waveformUpdateSubject, value - 1)
                }
            }
    }

    private func makePlayer() {
        player = ASAudioPlayer()
    }

    private func checkPlayerState() async -> Bool {
        if await isPlaying() {
            await player?.stopPlaying()
            await removePlayer()
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
        Logger.debug("녹음 시작")
        do {
            try await Task.sleep(nanoseconds: 6 * 1_000_000_000)
            let recordedData = await stopRecording()
            sendDataThrough(recorderDataSubject, recordedData ?? Data())
        } catch { Logger.error(error.localizedDescription) }
    }

    private func stopRecording() async -> Data? {
        let recordedData = await recorder?.stopRecording()
        Logger.debug("녹음 정지")
        recorderStateSubject.send(false)
        removeRecorder()
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

extension AudioHelper {
    enum FileSource: Equatable {
        case imported(MusicPanelType)
        case recorded
    }
}

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

    private func setPlayOption(option: PlayType) {
        playType = option
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
            await calculateAmplitude()
        }
    }

    private func calculateAmplitude() {
        Logger.debug("진폭계산 시작")
        cancellable = Timer.publish(every: 0.125, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                Task {
                    await self.calculateRecorderAmplitude()
                }
            }
    }

    private func calculateRecorderAmplitude() async {
        await recorder?.updateMeters()
        guard let averagePower = await recorder?.getAveragePower() else { return }
        let newAmplitude = 1.8 * pow(10.0, averagePower / 20.0)
        let clampedAmplitude = min(max(newAmplitude, 0), 1)
        amplitudeSubject.send(clampedAmplitude)
    }
}
