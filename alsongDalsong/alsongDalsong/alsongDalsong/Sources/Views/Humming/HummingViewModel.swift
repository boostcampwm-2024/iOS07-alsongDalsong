import ASEntity
import ASRepository
import Combine
import Foundation

final class HummingViewModel: ObservableObject, @unchecked Sendable {
    @Published public private(set) var dueTime: Date?
    @Published public private(set) var round: UInt8?
    @Published public private(set) var status: Status?
    @Published public private(set) var submissionStatus: (submits: String, total: String) = ("0", "0")
    @Published public private(set) var music: Music?
    @Published public private(set) var musicArtwork: Data?
    @Published public private(set) var musicPreview: Data?
    @Published public private(set) var humming: Data?
    @Published public private(set) var recorderAmplitude: Float = 0.0

    private let gameStatusRepository: GameStatusRepositoryProtocol
    private let playersRepository: PlayersRepositoryProtocol
    private var musicRepository: MusicRepositoryProtocol
    private let answersRepository: AnswersRepositoryProtocol
    private let submitsRepository: SubmitsRepositoryProtocol
    private var cancellables: Set<AnyCancellable> = []

    public init(
        gameStatusRepository: GameStatusRepositoryProtocol,
        playersRepository: PlayersRepositoryProtocol,
        musicRepository: MusicRepositoryProtocol,
        answersRepository: AnswersRepositoryProtocol,
        submitsRepository: SubmitsRepositoryProtocol
    ) {
        self.gameStatusRepository = gameStatusRepository
        self.playersRepository = playersRepository
        self.musicRepository = musicRepository
        self.answersRepository = answersRepository
        self.submitsRepository = submitsRepository
        bindGameStatus()
        bindSubmitStatus()
        bindAnswer()
        bindAmplitudeUpdates()
    }

    // TODO: - FB에 humming 보내기
    func submitHumming() {
        var myHumming = ASEntity.Record()
        myHumming.file = humming
//        myHumming.player = me
//        myHumming.round = round
    }

    @MainActor
    func startRecording() {
        Task {
            let data = await AudioHelper.shared.startRecording()
            humming = data
        }
    }

    func togglePlayPause(of type: AudioType, isPlaying: Bool = true) {
        Task {
            switch type {
                case .humming:
                    await AudioHelper.shared.startPlaying(file: humming)
                case .preview:
                    isPlaying ?
                        await AudioHelper.shared.stopPlaying() :
                        await AudioHelper.shared.startPlaying(file: musicPreview)
            }
        }
    }

    private func getPreview() {
        guard let music, let previewUrl = music.previewUrl else { return }
        musicRepository.getMusicData(url: previewUrl)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                    case .finished:
                        break
                    case let .failure(error):
                        print(error.localizedDescription)
                }
            } receiveValue: { [weak self] preview in
                self?.musicPreview = preview
            }
            .store(in: &cancellables)
    }

    private func bindAnswer() {
        answersRepository.getMyAnswer()
            .eraseToAnyPublisher()
            .sink { [weak self] answer in
                self?.music = answer?.music
                self?.getPreview()
            }
            .store(in: &cancellables)
    }

    private func bindAmplitudeUpdates() {
        Task {
            await AudioHelper.shared.amplitudePubisher()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] newAmplitude in
                    guard let self = self else { return }
                    self.recorderAmplitude = newAmplitude
                }
                .store(in: &self.cancellables)
        }
    }

    private func bindGameStatus() {
        gameStatusRepository.getDueTime()
            .sink { [weak self] newDueTime in
                self?.dueTime = newDueTime
            }
            .store(in: &cancellables)
        gameStatusRepository.getRound()
            .sink { [weak self] newRound in
                self?.round = newRound
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

    enum AudioType {
        case preview, humming
    }
}
