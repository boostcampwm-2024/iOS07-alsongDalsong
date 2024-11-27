import ASContainer
import ASEntity
import ASRepository
import Combine
import UIKit

@MainActor
final class GameNavigationController {
    private let navigationController: UINavigationController
    private let gameStateRepository: GameStateRepositoryProtocol
    private var subscriptions: Set<AnyCancellable> = []
    
    private var gameInfo: GameState? {
        didSet {
            guard let gameInfo else { return }
            updateViewControllers(state: gameInfo)
        }
    }
    
    init(navigationController: UINavigationController,
         gameStateRepository: GameStateRepositoryProtocol)
    {
        self.navigationController = navigationController
        self.gameStateRepository = gameStateRepository
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setConfiguration() {
        gameStateRepository.getGameState()
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] gameState in
                self?.gameInfo = gameState
            }
            .store(in: &subscriptions)
    }

    private func updateViewControllers(state: GameState) {
        let viewType = state.resolveViewType()
        switch viewType {
        case .selectMusic:
            navigateToSelectMusic()
        case .humming:
            navigateToHumming()
        case .rehumming:
            navigateToRehumming()
        case .result:
            navigateToResult()
        case .lobby:
            navigateToLobby()
        default:
            break
        }
    }
    
    private func navigateToLobby() {
        if navigationController.topViewController is LobbyViewController {
            return
        }
        
        if let vc = navigationController.viewControllers.first(where: { $0 is LobbyViewController }) {
            navigationController.popToViewController(vc, animated: true)
            return
        }
        
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
    
    private func navigateToSelectMusic() {
        let musicRepository = DIContainer.shared.resolve(MusicRepositoryProtocol.self)
        let answersRepository = DIContainer.shared.resolve(AnswersRepositoryProtocol.self)
        let gameStatusRepository = DIContainer.shared.resolve(GameStatusRepositoryProtocol.self)
        
        let vm = SelectMusicViewModel(
            musicRepository: musicRepository,
            answerRepository: answersRepository,
            gameStatusRepository: gameStatusRepository
        )
        let vc = SelectMusicViewController(selectMusicViewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func navigateToHumming() {
        let gameStatusRepository = DIContainer.shared.resolve(GameStatusRepositoryProtocol.self)
        let playersRepository = DIContainer.shared.resolve(PlayersRepositoryProtocol.self)
        let answersRepository = DIContainer.shared.resolve(AnswersRepositoryProtocol.self)
        let recordsRepository = DIContainer.shared.resolve(RecordsRepositoryProtocol.self)
        
        let vm = HummingViewModel(
            gameStatusRepository: gameStatusRepository,
            playersRepository: playersRepository,
            answersRepository: answersRepository,
            recordsRepository: recordsRepository
        )
        let vc = HummingViewController(vm: vm)
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func navigateToRehumming() {
        let gameStatusRepository = DIContainer.shared.resolve(GameStatusRepositoryProtocol.self)
        let playersRepository = DIContainer.shared.resolve(PlayersRepositoryProtocol.self)
        let recordsRepository = DIContainer.shared.resolve(RecordsRepositoryProtocol.self)
        
        let vm = RehummingViewModel(
            gameStatusRepository: gameStatusRepository,
            playersRepository: playersRepository,
            recordsRepository: recordsRepository
        )
        let vc = RehummingViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func navigateToResult() {
        let hummingResultRepository = DIContainer.shared.resolve(HummingResultRepositoryProtocol.self)
        let avatarRepository = DIContainer.shared.resolve(AvatarRepositoryProtocol.self)
        let gameStatusRepository = DIContainer.shared.resolve(GameStatusRepositoryProtocol.self)
        let playerRepository = DIContainer.shared.resolve(PlayersRepositoryProtocol.self)
        let roomActionRepository = DIContainer.shared.resolve(RoomActionRepositoryProtocol.self)
        let roomInfoRepository = DIContainer.shared.resolve(RoomInfoRepositoryProtocol.self)
        let vm = HummingResultViewModel(
            hummingResultRepository: hummingResultRepository,
            avatarRepository: avatarRepository,
            gameStatusRepository: gameStatusRepository,
            playerRepository: playerRepository,
            roomActionRepository: roomActionRepository,
            roomInfoRepository: roomInfoRepository
        )
        let vc = HummingResultViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func navigationToWaiting() {}
}
