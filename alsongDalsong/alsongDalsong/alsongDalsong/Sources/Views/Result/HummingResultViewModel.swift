import ASAudioKit
import ASEntity
import ASLogKit
import ASRepositoryProtocol
import Combine
import Foundation

typealias Result = (answer: Answer?, records: [ASEntity.Record]?, submit: Answer?)

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
    @Published var result: Result = (nil, nil, nil)

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
        bindResult()
        bindPlayers()
        bindRoomNumber()
        bindRecordOrder()
    }

    private func updateCurrentResult() {
        guard let next = hummingResult.first else { return }
        currentResult = next.answer
        result = (next.answer, next.records, next.submit)
        hummingResult.removeFirst()
    }

    func nextResultFetch() {
        if hummingResult.isEmpty { return }
        let current = hummingResult.removeFirst()
        currentResult = current.answer
        result.records = current.records
        result.submit = current.submit
        currentRecords.removeAll()
        currentsubmit = nil
    }

    func getAvatarData(url: URL?) async -> Data? {
        guard let url else { return nil }
        return await avatarRepository.getAvatarData(url: url)
    }

    func changeRecordOrder() async throws {
        do {
            let succeded = try await roomActionRepository.changeRecordOrder(roomNumber: roomNumber)
            if !succeded { Logger.error("Changing RecordOrder failed") }
        } catch {
            Logger.error(error.localizedDescription)
            throw error
        }
    }

    func navigateToLobby() async throws {
        do {
            if !hummingResult.isEmpty { return }
            let succeded = try await roomActionRepository.resetGame()
            if !succeded { Logger.error("Game Reset failed") }
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

// MARK: - Playing music

extension HummingResultViewModel {
    func startPlaying() async {
        await startPlayingCurrentMusic()
        guard var records = result.records else { return }
        while !records.isEmpty {
            currentRecords.append(records.removeFirst())
            guard let fileUrl = currentRecords.last?.fileUrl else { continue }
            let data = await hummingResultRepository.getRecordData(url: fileUrl)
            await AudioHelper.shared.startPlaying(data)
            await waitForPlaybackToFinish()
        }
        currentsubmit = result.submit
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
}

// MARK: - Bind with Repositories
extension HummingResultViewModel {
    private func bindPlayers() {
        playerRepository.isHost()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isHost in
                self?.isHost = isHost
            }
            .store(in: &cancellables)
    }

    private func bindRoomNumber() {
        roomInfoRepository.getRoomNumber()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] roomNumber in
                self?.roomNumber = roomNumber
            }
            .store(in: &cancellables)
    }

    private func bindRecordOrder() {
        Publishers.CombineLatest(gameStatusRepository.getStatus(), gameStatusRepository.getRecordOrder())
            .receive(on: DispatchQueue.main)
            .sink { status, _ in
                if status == .result, self.recordOrder != 0 {
                    self.isNext = true
                } else {
                    self.recordOrder! += 1
                }
            }
            .store(in: &cancellables)
    }

    func bindResult() {
        hummingResultRepository.getResult()
            .receive(on: DispatchQueue.main)
            .map { $0.sorted { $0.answer.player?.order ?? 0 < $1.answer.player?.order ?? 1 } }
            .sink(receiveCompletion: { Logger.debug($0) },
                  receiveValue: { [weak self] sortedResult in
                      guard let self, isValidResult(sortedResult) else { return }

                      hummingResult = sortedResult.map { ($0.answer, $0.records, $0.submit) }
                      Logger.debug("hummingResult \(hummingResult)")

                      updateCurrentResult()
                  })
            .store(in: &cancellables)
    }
    
    private func isValidResult(_ sortedResult: [(answer: Answer, records: [ASEntity.Record], submit: Answer, recordOrder: UInt8)]) -> Bool {
        guard let firstRecordOrder = sortedResult.first?.recordOrder else { return false }
        return (sortedResult.count - 1) >= firstRecordOrder
    }
}
