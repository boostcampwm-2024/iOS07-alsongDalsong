import ASContainer
import ASEntity
import ASRepository
import Combine
import UIKit

@MainActor
final class GameNavigationController {
    private let navigationController: UINavigationController
    private var subscriptions: Set<AnyCancellable> = []
    
    private let roomInfoRepository: RoomInfoRepositoryProtocol = DIContainer.shared.resolve(RoomInfoRepositoryProtocol.self)
    private let gameStatusRepository: GameStatusRepositoryProtocol = DIContainer.shared.resolve(GameStatusRepositoryProtocol.self)
    private let playersRepository: PlayersRepositoryProtocol = DIContainer.shared.resolve(PlayersRepositoryProtocol.self)
    private var players: [Player] = []
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        setupBinding()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setupBinding() {
        let modePublisher = roomInfoRepository.getMode()
        let recordOrderPublisher = roomInfoRepository.getRecordOrder()
        let statusPublisher = gameStatusRepository.getStatus()
        let roundPublisher = gameStatusRepository.getRound()

        Publishers.CombineLatest4(modePublisher, recordOrderPublisher, statusPublisher, roundPublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] mode, recordOrder, status, round in
                self?.updateViewControllers(mode: mode, recordOrder: recordOrder, status: status, round: round)
            }
            .store(in: &subscriptions)
        
        playersRepository.getPlayers()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] players in
                self?.players = players
            }
            .store(in: &subscriptions)
        
        roomInfoRepository.getRoomNumber()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.navigateToLobby()
            }
            .store(in: &subscriptions)
    }

    private func updateViewControllers(mode: Mode, recordOrder: UInt8, status: Status?, round: UInt8) {
        guard let status else { navigateToLobby(); return }
        switch mode {
        case .humming:
            setHummingModeNavigation(status: status, recordOrder: recordOrder, round: round)
        case .harmony:
            setHarmonyModeNavigation(status: status, round: round)
        case .sync:
            setSyncModeNavigation(status: status, round: round)
        case .instant:
            setInstantModeNavigation(status: status, round: round)
        case .tts:
            setTTSModeNavigation(status: status, round: round)
        default:
            break
        }
    }
    
    private func setHummingModeNavigation(status: Status, recordOrder: UInt8, round: UInt8) {
        let playerCount = UInt8(players.count)
        switch status {
        case .humming:
            if round == 0, recordOrder == 0 {
                navigateToSelectMusic()
            } else if round == 1, recordOrder == 0 {
                navigateToHumming()
            }
        case .rehumming:
            if round == 1, recordOrder >= 1, recordOrder <= playerCount - 1 {
                navigateToRehumming()
            }
        case .result:
            navigateToResult()
        default:
            navigateToLobby()
        }
    }
    
    private func setHarmonyModeNavigation(status: Status, round: UInt8) {}
    
    private func setSyncModeNavigation(status: Status, round: UInt8) {}
    
    private func setInstantModeNavigation(status: Status, round: UInt8) {}
    
    private func setTTSModeNavigation(status: Status, round: UInt8) {}
    
    private func navigateToLobby() {
        if let vc = navigationController.viewControllers.first(where: { $0 is LobbyViewController }) {
            navigationController.popToViewController(vc, animated: true)
        } else {
            let roomInfoRepository: RoomInfoRepositoryProtocol = DIContainer.shared.resolve(RoomInfoRepositoryProtocol.self)
            let playersRepository: PlayersRepositoryProtocol = DIContainer.shared.resolve(PlayersRepositoryProtocol.self)
            let roomActionRepository: RoomActionRepositoryProtocol = DIContainer.shared.resolve(RoomActionRepositoryProtocol.self)
            let avatarRepository: AvatarRepositoryProtocol = DIContainer.shared.resolve(AvatarRepositoryProtocol.self)
        
            let vm = LobbyViewModel(
                playersRepository: playersRepository,
                roomInfoRepository: roomInfoRepository,
                roomActionRepository: roomActionRepository,
                avatarRepository: avatarRepository
            )
            let vc = LobbyViewController(lobbyViewModel: vm)
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    private func navigateToSelectMusic() {
        let musicRepository = DIContainer.shared.resolve(MusicRepositoryProtocol.self)
        
        let vm = SelectMusicViewModel(musicRepository: musicRepository)
        let vc = SelectMusicViewController(selectMusicViewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func navigateToHumming() {
        let gameStatusRepository = DIContainer.shared.resolve(GameStatusRepositoryProtocol.self)
        let playersRepository = DIContainer.shared.resolve(PlayersRepositoryProtocol.self)
        let submitsRepository = DIContainer.shared.resolve(SubmitsRepositoryProtocol.self)
        
        let vm = HummingViewModel(
            gameStatusRepository: gameStatusRepository,
            playersRepository: playersRepository,
            submitsRepository: submitsRepository
        )
        let vc = HummingViewController(vm: vm)
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func navigateToRehumming() {
        let gameStatusRepository = DIContainer.shared.resolve(GameStatusRepositoryProtocol.self)
        let playersRepository = DIContainer.shared.resolve(PlayersRepositoryProtocol.self)
        let submitsRepository = DIContainer.shared.resolve(SubmitsRepositoryProtocol.self)
        let recordsRepository = DIContainer.shared.resolve(RecordsRepositoryProtocol.self)
        
        let vm = RehummingViewModel(
            gameStatusRepository: gameStatusRepository,
            playersRepository: playersRepository,
            recordsRepository: recordsRepository,
            submitsRepository: submitsRepository
        )
        let vc = RehummingViewController(vm: vm)
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func navigateToResult() {
        let vc = HummingResultViewController()
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func navigationToWaiting() {}
}
