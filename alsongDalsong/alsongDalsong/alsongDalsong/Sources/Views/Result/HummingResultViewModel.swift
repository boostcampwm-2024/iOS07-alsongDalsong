import ASAudioKit
import ASEntity
import ASLogKit
import ASRepositoryProtocol
import Combine
import Foundation

final class HummingResultViewModel: @unchecked Sendable {
    private var hummingResultRepository: HummingResultRepositoryProtocol
    private var avatarRepository: AvatarRepositoryProtocol
    private var gameStatusRepository: GameStatusRepositoryProtocol
    private var playerRepository: PlayersRepositoryProtocol
    private var roomActionRepository: RoomActionRepositoryProtocol
    private var roomInfoRepository: RoomInfoRepositoryProtocol
    private var musicRepository: MusicRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    @Published var isNext: Bool = false
    @Published var currentResult: Answer?
    @Published var currentRecords: [ASEntity.Record] = []
    @Published var currentsubmit: Answer?
    @Published var recordOrder: UInt8? = 0
    @Published var isHost: Bool = false

    // 미리 받아놓을 정보 배열
    private var recordsResult: [ASEntity.Record] = []
    private var submitsResult: Answer?
    private var roomNumber: String = ""

    var hummingResult: [(answer: ASEntity.Answer, records: [ASEntity.Record], submit: ASEntity.Answer)] = []

    init(hummingResultRepository: HummingResultRepositoryProtocol,
         avatarRepository: AvatarRepositoryProtocol,
         gameStatusRepository: GameStatusRepositoryProtocol,
         playerRepository: PlayersRepositoryProtocol,
         roomActionRepository: RoomActionRepositoryProtocol,
         roomInfoRepository: RoomInfoRepositoryProtocol,
         musicRepository: MusicRepositoryProtocol)
    {
        self.hummingResultRepository = hummingResultRepository
        self.avatarRepository = avatarRepository
        self.gameStatusRepository = gameStatusRepository
        self.playerRepository = playerRepository
        self.roomActionRepository = roomActionRepository
        self.roomInfoRepository = roomInfoRepository
        self.musicRepository = musicRepository
        fetchResult()
    }

    func fetchResult() {
        hummingResultRepository.getResult()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                // TODO: 성공 실패 여부에 따른 처리
                Logger.debug(completion)
            } receiveValue: { [weak self] (result: [(answer: ASEntity.Answer, records: [ASEntity.Record], submit: ASEntity.Answer, recordOrder: UInt8)]) in
                guard let self else { return }

                if (result.count - 1) < result.first?.recordOrder ?? 0 { return }
                Logger.debug("호출")
                hummingResult = result.map {
                    (answer: $0.answer, records: $0.records, submit: $0.submit)
                }

                hummingResult.sort {
                    $0.answer.player?.order ?? 0 < $1.answer.player?.order ?? 1
                }

                Logger.debug("hummingResult \(hummingResult)")

                let current = hummingResult.removeFirst()
                currentResult = current.answer
                recordsResult = current.records
                submitsResult = current.submit
            }
            .store(in: &cancellables)

        playerRepository.isHost()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isHost in
                self?.isHost = isHost
            }
            .store(in: &cancellables)

        roomInfoRepository.getRoomNumber()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] roomNumber in
                self?.roomNumber = roomNumber
            }
            .store(in: &cancellables)

        Publishers.CombineLatest(gameStatusRepository.getStatus(), gameStatusRepository.getRecordOrder())
            .receive(on: DispatchQueue.main)
            .sink { status, _ in
                // order에 초기값이 들어오는 문제
                if status == .result, self.recordOrder != 0 {
                    self.isNext = true
                } else {
                    self.recordOrder! += 1
                }
            }
            .store(in: &cancellables)
    }

    func startPlaying() async {
        await startPlayingCurrentMusic()

        while !recordsResult.isEmpty {
            currentRecords.append(recordsResult.removeFirst())
            guard let fileUrl = currentRecords.last?.fileUrl else { continue }
            do {
                let data = try await fetchRecordData(url: fileUrl)
                await AudioHelper.shared.startPlaying(data)
                await waitForPlaybackToFinish()
            } catch {
                Logger.error("녹음 파일 다운로드에 실패하였습니다.")
            }
        }
        currentsubmit = submitsResult
    }

    private func startPlayingCurrentMusic() async {
        guard let fileUrl = currentResult?.music?.previewUrl else { return }
        let data = await musicRepository.getMusicData(url: fileUrl)
        await AudioHelper.shared.startPlaying(data, option: .partial(time: 10))
        await waitForPlaybackToFinish()
    }

    private func waitForPlaybackToFinish() async {
        await withCheckedContinuation { continuation in
            Task {
                while await AudioHelper.shared.isPlaying() {
                    try? await Task.sleep(nanoseconds: 100_000_000)
                }
                continuation.resume()
            }
        }
    }

    func nextResultFetch() {
        if hummingResult.isEmpty { return }
        let current = hummingResult.removeFirst()
        currentResult = current.answer
        recordsResult = current.records
        submitsResult = current.submit
        currentRecords.removeAll()
        currentsubmit = nil
    }

    private func getRecordData(url: URL?) -> AnyPublisher<Data?, Error> {
        if let url {
            hummingResultRepository.getRecordData(url: url)
                .eraseToAnyPublisher()
        } else {
            Just(nil)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }

    private func fetchRecordData(url: URL) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            getRecordData(url: url)
                .compactMap { $0 }
                .sink(receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        continuation.resume(throwing: error)
                    }
                }, receiveValue: { data in
                    continuation.resume(returning: data)
                })
                .store(in: &cancellables)
        }
    }

    func getAvatarData(url: URL?) async -> Data? {
        guard let url else { return nil }
        return await avatarRepository.getAvatarData(url: url)
    }

    func changeRecordOrder() async throws {
        do {
            try await roomActionRepository.changeRecordOrder(roomNumber: roomNumber)
        } catch {
            Logger.error(error.localizedDescription)
            throw error
        }
    }

    func navigationToLobby() async throws {
        do {
            if !hummingResult.isEmpty { return }
            try await roomActionRepository.resetGame()
        } catch {
            throw error
        }
    }

    func getArtworkData(url: URL?) async -> Data? {
        guard let url else { return nil }
        return await musicRepository.getMusicData(url: url)
    }

    func cancelSubscriptions() {
        cancellables.removeAll()
    }
}
