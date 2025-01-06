import ASEntity
import ASLogKit
import ASRepositoryProtocol
import Combine
import Foundation

typealias Result = (
    answer: MappedAnswer?,
    records: [MappedRecord],
    submit: MappedAnswer?
)

final class HummingResultViewModel: @unchecked Sendable {
    private var hummingResultRepository: HummingResultRepositoryProtocol
    private var gameStatusRepository: GameStatusRepositoryProtocol
    private var playerRepository: PlayersRepositoryProtocol
    private var roomActionRepository: RoomActionRepositoryProtocol
    private var roomInfoRepository: RoomInfoRepositoryProtocol
    private var dataDownloadRepository: DataDownloadRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    @Published var recordOrder: UInt8? = 0
    @Published var isHost: Bool = false
    @Published var result: Result = (nil, [], nil)
    @Published var resultPhase: ResultPhase = .none
    @Published var canEndGame: Bool = false

    var totalResult: [(answer: ASEntity.Answer, records: [ASEntity.Record], submit: ASEntity.Answer)] = []

    var resultEnded: Bool {
        totalResult.isEmpty
    }

    private var roomNumber: String = ""

    init(hummingResultRepository: HummingResultRepositoryProtocol,
         gameStatusRepository: GameStatusRepositoryProtocol,
         playerRepository: PlayersRepositoryProtocol,
         roomActionRepository: RoomActionRepositoryProtocol,
         roomInfoRepository: RoomInfoRepositoryProtocol,
         dataDownloadRepository: DataDownloadRepositoryProtocol)
    {
        self.hummingResultRepository = hummingResultRepository
        self.gameStatusRepository = gameStatusRepository
        self.playerRepository = playerRepository
        self.roomActionRepository = roomActionRepository
        self.roomInfoRepository = roomInfoRepository
        self.dataDownloadRepository = dataDownloadRepository
        bindPlayers()
        bindRoomNumber()
        bindRecordOrder()
        bindAudio()
    }

    /// RecordOrder 증가 시 호출, totalResult에서 첫번째 index를 pop하고 새로운 result로 변경
    private func updateCurrentResult() {
        Task {
            guard !totalResult.isEmpty else { return }
            let displayableResult = totalResult.removeFirst()
            let answer = await mapAnswer(displayableResult.answer)
            let records = await mapRecords(displayableResult.records)
            let submit = await mapAnswer(displayableResult.submit)
            result = (answer, records, submit)
            Logger.debug("updateCurrentResult에서 한번")
            updateResultPhase()
        }
    }

    /// 오디오 재생이 끝난 후 호출, answer -> records(0...count) -> submit -> answer로 변경
    /// 변경 후 바로 오디오 재생 시작
    /// submit -> answer의 경우에는 recordOrder만 변경
    private func updateResultPhase() {
        Task {
            switch resultPhase {
                case .answer:
                    Logger.debug("Answer Play")
                    resultPhase = .record(0)
                    await startPlaying()
                case let .record(count):
                    Logger.debug("Record \(count) Play")
                    if result.records.count - 1 == count { resultPhase = .submit }
                    else { resultPhase = .record(count + 1) }
                    await startPlaying()
                case .submit:
                    Logger.debug("Submit Play")
                    resultPhase = .none
                    await startPlaying()
                    if totalResult.isEmpty { canEndGame = true }
                case .none:
                    Logger.debug("None")
                    resultPhase = .answer
                    await startPlaying()
            }
        }
    }

    func changeRecordOrder() async {
        do {
            let succeded = try await roomActionRepository.changeRecordOrder(roomNumber: roomNumber)
            if !succeded { Logger.error("Changing RecordOrder failed") }
        } catch {
            Logger.error(error.localizedDescription)
        }
    }

    func navigateToLobby() async {
        do {
            guard totalResult.isEmpty else { return }
            let succeded = try await roomActionRepository.resetGame()
            if !succeded { Logger.error("Game Reset failed") }
        } catch {
            Logger.error("Game Reset failed")
        }
    }

    func cancelSubscriptions() {
        cancellables.removeAll()
    }

    private func mapAnswer(_ answer: Answer) async -> MappedAnswer {
        let artworkData = await getArtworkData(answer.music)
        let previewData = await getPreviewData(answer.music)
        let title = answer.music?.title
        let artist = answer.music?.artist
        let playerName = answer.player?.nickname
        let playerAvatarData = await getAvatarData(url: answer.player?.avatarUrl)
        return MappedAnswer(artworkData, previewData, title, artist, playerName, playerAvatarData)
    }

    private func mapRecords(_ records: [ASEntity.Record]) async -> [MappedRecord] {
        var mappedRecords = [MappedRecord]()

        for record in records {
            let recordData = await getRecordData(url: record.fileUrl)
            let recordAmplitudes = await AudioHelper.shared.analyze(with: recordData ?? Data())
            Logger.debug(recordAmplitudes)
            let playerName = record.player?.nickname
            let playerAvatarData = await getAvatarData(url: record.player?.avatarUrl)
            mappedRecords.append(MappedRecord(recordData, recordAmplitudes, playerName, playerAvatarData))
        }

        return mappedRecords
    }
}

// MARK: - Play music

extension HummingResultViewModel {
    func startPlaying() async {
        let audioData = resultPhase.audioData(result)
        let playOption = resultPhase.playOption
        await AudioHelper.shared.startPlaying(audioData, option: playOption)
    }
}

// MARK: - Bind with Repositories

extension HummingResultViewModel {
    private func bindPlayers() {
        playerRepository.isHost()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isHost in
                guard let self else { return }
                self.isHost = isHost
            }
            .store(in: &cancellables)
    }

    private func bindRoomNumber() {
        roomInfoRepository.getRoomNumber()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] roomNumber in
                guard let self else { return }
                self.roomNumber = roomNumber
            }
            .store(in: &cancellables)
    }

    private func bindRecordOrder() {
        Publishers.CombineLatest(gameStatusRepository.getStatus(), gameStatusRepository.getRecordOrder())
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] _, recordOrder in
                guard let self else { return }
                Logger.debug("recordOrder changed", recordOrder)
                self.recordOrder = recordOrder
                updateCurrentResult()
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

                      totalResult = sortedResult.map { ($0.answer, $0.records, $0.submit) }
                      updateCurrentResult()
                  })
            .store(in: &cancellables)
    }

    private func bindAudio() {
        Task {
            await AudioHelper.shared.playerStatePublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _, isPlaying in
                    guard let self else { return }
                    if !isPlaying {
                        self.updateResultPhase()
                    }
                }
                .store(in: &cancellables)
        }
    }

    func isValidResult(_ sortedResult: [(answer: Answer, records: [ASEntity.Record], submit: Answer, recordOrder: UInt8)]) -> Bool {
        guard let firstRecordOrder = sortedResult.first?.recordOrder else { return false }
        return (sortedResult.count - 1) >= firstRecordOrder
    }
}

// MARK: - Data Download

private extension HummingResultViewModel {
    private func getAvatarData(url: URL?) async -> Data? {
        guard let url else { return nil }
        return await dataDownloadRepository.downloadData(url: url)
    }

    private func getArtworkData(_ music: Music?) async -> Data? {
        guard let url = music?.artworkUrl else { return nil }
        return await dataDownloadRepository.downloadData(url: url)
    }

    private func getPreviewData(_ music: Music?) async -> Data? {
        guard let url = music?.previewUrl else { return nil }
        return await dataDownloadRepository.downloadData(url: url)
    }

    private func getRecordData(url: URL?) async -> Data? {
        guard let url else { return nil }
        return await dataDownloadRepository.downloadData(url: url)
    }
}
