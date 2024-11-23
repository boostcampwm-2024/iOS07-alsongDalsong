import Foundation
import ASEntity
import ASRepository
import Combine

final class LobbyViewModel: ObservableObject {
    private var playersRepository: PlayersRepositoryProtocol
    private var roomInfoRepository: RoomInfoRepositoryProtocol
    private var roomActionRepository: RoomActionRepositoryProtocol
    private var avatarRepository: AvatarRepositoryProtocol
    
    let playerMaxCount = 4
    @Published var players: [Player] = []
    @Published var roomNumber: String = ""
    @Published var mode: Mode = .humming {
        didSet {
            print("mode: \(mode)")
        }
    }
    @Published var host: Player?
    @Published var isGameStrted: Bool = false
    @Published var isHost: Bool = false
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(playersRepository: PlayersRepositoryProtocol,
         roomInfoRepository: RoomInfoRepositoryProtocol,
         roomActionRepository: RoomActionRepositoryProtocol,
         avatarRepository: AvatarRepositoryProtocol)
    {
        self.playersRepository = playersRepository
        self.roomActionRepository = roomActionRepository
        self.roomInfoRepository = roomInfoRepository
        self.avatarRepository = avatarRepository
        
        fetchData()
    }
    
    func getAvatarData(url: URL?) -> AnyPublisher<Data?, Error> {
        if let url {
            return avatarRepository.getAvatarData(url: url)
                .eraseToAnyPublisher()
        }else {
            return Just(nil)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
    
    func gameStart() {
        // HOST인지 검사 필요
        roomActionRepository.startGame(roomNumber: roomNumber)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] isSuccess in
                self?.isGameStrted = isSuccess
            }
            .store(in: &cancellables)
    }
    
    func leaveRoom() {
        roomActionRepository.leaveRoom()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] isSuccess in
                if isSuccess {
                    // navigate to Onboarding
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchData() {
        playersRepository.getPlayers()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] players in
                self?.players = players
            }
            .store(in: &cancellables)
        
        playersRepository.getHost()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] host in
                self?.host = host
            }
            .store(in: &cancellables)
        
        roomInfoRepository.getMode()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] mode in
                self?.mode = mode
            }
            .store(in: &cancellables)
        
        roomInfoRepository.getRoomNumber()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] roomNumber in
                self?.roomNumber = roomNumber
            }
            .store(in: &cancellables)
        
        playersRepository.isHost()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isHost in
                self?.isHost = isHost
            }
            .store(in: &cancellables)
    }
}

struct ModeInfo: Identifiable {
    var id: UUID = UUID()
    let title: String
    let imageName: String
    let description: String
    
    static let modeInfos: [ModeInfo] = [
        ModeInfo(title: "허밍", imageName: "fake", description: String(localized: "HummingModeDescription")),
        ModeInfo(title: "하모니", imageName: "fake", description: String(localized: "HarmonyModeDescription")),
        ModeInfo(title: "이구동성", imageName: "fake", description: String(localized: "SyncModeDescription")),
        ModeInfo(title: "찰나의순간", imageName: "fake", description: String(localized: "InstantModeDescription")),
        ModeInfo(title: "TTS", imageName: "fake", description: String(localized: "TTSModeDescription")),
    ]
}
