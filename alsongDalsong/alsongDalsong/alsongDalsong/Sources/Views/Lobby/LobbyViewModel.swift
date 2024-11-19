import Foundation
import ASNetworkKit
import ASEntity
import ASRepository
import Combine

final class LobbyViewModel: ObservableObject {
    private var mainRepository: MainRepository
    private var playersRepository: PlayersRepository
    private var roomInfoRepository: RoomInfoRepository
    let playerMaxCount = 4
    @Published var players: [Player] = []
    @Published var roomNumber: String = ""
    @Published var mode: Mode = .humming
    @Published var host: Player?
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
        self.playersRepository = PlayersRepository(mainRepository: self.mainRepository)
        self.roomInfoRepository = RoomInfoRepository(mainRepository: self.mainRepository)
    }
    
    func fetchData() {
        playersRepository.getPlayers()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] players in
                self?.players = players
                for i in 0..<(self?.playerMaxCount ?? 4) - players.count {
                    self?.players.append(Player(id: "0000000\(i)"))
                }
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
