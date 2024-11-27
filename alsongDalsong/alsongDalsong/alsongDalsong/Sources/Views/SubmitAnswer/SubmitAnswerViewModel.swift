import ASEntity
import ASMusicKit
import ASRepository
import Combine
import Foundation
import MusicKit

final class SubmitAnswerViewModel: ObservableObject, @unchecked Sendable {
    private var cancellable = Set<AnyCancellable>()
    private let musicRepository: MusicRepositoryProtocol
    private let gameStatusRepository: GameStatusRepositoryProtocol
    private let playersRepository: PlayersRepositoryProtocol
    private let recordsRepository: RecordsRepositoryProtocol
    private let submitsRepository: SubmitsRepositoryProtocol
    private var cancellables: Set<AnyCancellable> = []

    let musicAPI = ASMusicAPI()

    @Published var musicData: Data? {
        didSet {
            isPlaying = true
        }
    }

    @Published var searchList: [ASSong] = []
    @Published var selectedSong: ASSong = .init(
        id: "12345",
        title: "선택된 곡 없음",
        artistName: "아티스트",
        artwork: nil,
        previewURL: URL(string: "")
    )
    @Published var isPlaying: Bool = false {
        didSet {
            if isPlaying {
                playingMusic()
            } else {
                stopMusic()
            }
        }
    }

    @Published private(set) var dueTime: Date?
    @Published private(set) var recordOrder: UInt8?
    @Published private(set) var status: Status?
    @Published private(set) var submissionStatus: (submits: String, total: String) = ("0", "0")
    @Published private(set) var music: Music?
    @Published private(set) var recordedData: Data?
    @Published private(set) var isRecording: Bool = false

    init(
        gameStatusRepository: GameStatusRepositoryProtocol,
        playersRepository: PlayersRepositoryProtocol,
        recordsRepository: RecordsRepositoryProtocol,
        submitsRepository: SubmitsRepositoryProtocol,
        musicRepository: MusicRepositoryProtocol
    ) {
        self.gameStatusRepository = gameStatusRepository
        self.playersRepository = playersRepository
        self.recordsRepository = recordsRepository
        self.submitsRepository = submitsRepository
        self.musicRepository = musicRepository
        bindGameStatus()
        bindSubmitStatus()
    }

    func downloadMusic(url: URL?) {
        guard let url else { return }
        musicRepository.getMusicData(url: url)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] data in
                self?.musicData = data
            }
            .store(in: &cancellable)
    }

    func playingMusic() {
        guard let data = musicData else { return }
        Task {
            await AudioHelper.shared.startPlaying(file: data)
        }
    }

    func stopMusic() {
        Task {
            await AudioHelper.shared.stopPlaying()
        }
    }

    func handleSelectedSong(song: ASSong) {
        selectedSong = song
        beginPlaying()
    }

    func beginPlaying() {
        downloadMusic(url: selectedSong.previewURL)
    }

    func submitAnswer() async {
        guard let artworkBackgroundColor = selectedSong.artwork?.backgroundColor?.toHex() else { return }
        let answer = ASEntity.Music(
            title: selectedSong.title,
            artist: selectedSong.artistName,
            artworkUrl: selectedSong.artwork?.url(width: 300, height: 300),
            previewUrl: selectedSong.previewURL,
            artworkBackgroundColor: artworkBackgroundColor
        )
        do {
            let response = try await submitsRepository.submitAnswer(answer: answer)
        } catch {
            print(error.localizedDescription)
        }
    }

    @MainActor
    func searchMusic(text: String) {
        Task {
            searchList = await musicAPI.search(for: text)
        }
    }

    // MARK: - 이부분 부터 RehummingViewModel

    func startRecording() {
        isRecording = true
    }

    @MainActor
    func togglePlayPause() {
        Task {
            await AudioHelper.shared.startPlaying(file: recordedData)
        }
    }

    func updateRecordedData(with data: Data) {
        // TODO: - data가 empty일 때(녹음이 제대로 되지 않았을 때 사용자 오류처리 필요
        guard !data.isEmpty else { return }
        recordedData = data
        isRecording = false
    }

    private func bindRecord(on recordOrder: UInt8) {
        recordsRepository.getHumming(on: recordOrder)
            .sink { [weak self] record in
                guard let record else { return }
                self?.music = Music(record)
            }
            .store(in: &cancellables)
    }

    private func bindGameStatus() {
        gameStatusRepository.getDueTime()
            .sink { [weak self] newDueTime in
                self?.dueTime = newDueTime
            }
            .store(in: &cancellables)
        gameStatusRepository.getRecordOrder()
            .sink { [weak self] newRecordOrder in
                self?.recordOrder = newRecordOrder
                self?.bindRecord(on: newRecordOrder)
            }
            .store(in: &cancellables)
        gameStatusRepository.getStatus()
            .sink { [weak self] newStatus in
                self?.status = newStatus
            }
            .store(in: &cancellables)
    }

    private func bindSubmitStatus() {
        let playerPublisher = playersRepository.getPlayers()
        let submitsPublisher = submitsRepository.getSubmits()

        playerPublisher.zip(submitsPublisher)
            .sink { [weak self] players, submits in
                let submitStatus = (submits: String(submits.count), total: String(players.count))
                self?.submissionStatus = submitStatus
            }
            .store(in: &cancellables)
    }
}
