import ASEntity
import ASRepository
import Combine
import Foundation

final class LobbyViewModel: ObservableObject, @unchecked Sendable {
    private var playersRepository: PlayersRepositoryProtocol
    private var roomInfoRepository: RoomInfoRepositoryProtocol
    private var roomActionRepository: RoomActionRepositoryProtocol
    private var avatarRepository: AvatarRepositoryProtocol
    
    let playerMaxCount = 4
    @Published var players: [Player] = []
    @Published var roomNumber: String = ""
    @Published var mode: Mode = .humming {
        didSet {
            if mode != oldValue {
                changeMode()
            }
        }
    }

    @Published var host: Player?
    @Published var isGameStrted: Bool = false
    @Published var isHost: Bool = false
    var isLeaveRoom = false
    
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
            avatarRepository.getAvatarData(url: url)
                .eraseToAnyPublisher()
        } else {
            Just(nil)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
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
                guard let isHost = self?.isHost else { return }
                if !isHost {
                    self?.mode = mode
                }
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
    
    func gameStart() {
        Task {
            do {
                let isGameStarted = try await roomActionRepository.startGame(roomNumber: roomNumber)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func leaveRoom() {
        Task {
            do {
                isLeaveRoom = try await roomActionRepository.leaveRoom()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func changeMode() {
        Task {
            do {
                if isHost {
                    try await self.roomActionRepository.changeMode(roomNumber: roomNumber, mode: mode)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
