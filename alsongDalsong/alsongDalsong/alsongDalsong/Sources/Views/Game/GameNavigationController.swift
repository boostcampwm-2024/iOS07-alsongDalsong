import ASContainer
import ASEntity
import ASLogKit
import ASRepositoryProtocol
import Combine
import UIKit

@MainActor
final class GameNavigationController {
    private let navigationController: UINavigationController
    private let gameStateRepository: GameStateRepositoryProtocol
    private let roomActionRepository: RoomActionRepositoryProtocol
    private var subscriptions: Set<AnyCancellable> = []
    
    private var gameInfo: GameState? {
        didSet {
            guard let gameInfo else { return }
            updateViewControllers(state: gameInfo)
        }
    }
    
    private let roomNumber: String
    
    init(navigationController: UINavigationController,
         gameStateRepository: GameStateRepositoryProtocol,
         roomActionRepository: RoomActionRepositoryProtocol,
         roomNumber: String)
    {
        self.navigationController = navigationController
        self.gameStateRepository = gameStateRepository
        self.roomActionRepository = roomActionRepository
        self.roomNumber = roomNumber
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
    
    private func setupNavigationBar(for viewController: UIViewController) {
        Logger.debug("setupNavi 시작")
        navigationController.navigationBar.isHidden = false
        navigationController.navigationBar.tintColor = .asBlack
        navigationController.navigationBar.titleTextAttributes = [.font: UIFont.font(.dohyeon, ofSize: 24)]
        
        let backButtonImage = UIImage(systemName: "rectangle.portrait.and.arrow.forward")?
            .withRenderingMode(.alwaysTemplate)
            .applyingSymbolConfiguration(.init(pointSize: 24, weight: .medium))?
            .rotate(radians: .pi)
        
        let backButtonAction = UIAction { [weak self] _ in
            let alert = ASAlertController(
                style: .default,
                titleText: .leaveRoom,
                doneButtonTitle: .leave,
                cancelButtonTitle: .cancel
            ) { [weak self] _ in
                //                self?.viewmodel.leaveRoom()
                self?.navigationController.popViewController(animated: true)  // 아예 온보딩으로 가야함.
            }
            self?.navigationController.presentAlert(alert)
        }

        let backButton = UIBarButtonItem(image: backButtonImage, primaryAction: backButtonAction)
        
        viewController.navigationItem.leftBarButtonItem = backButton
        viewController.title = setTitle()
    }
    
    private func setTitle() -> String {
        switch gameInfo?.resolveViewType() {
        case .submitMusic:
            return "노래 선택"
        case .humming:
            return "허밍"
        case .rehumming:
            return "리허밍"
        case .submitAnswer:
            return "정답 제출"
        case .result:
            return "결과 확인"
        case .lobby:
            return "#\(roomNumber)"
        default:
            return ""
        }
    }
    
    private func updateViewControllers(state: GameState) {
        let viewType = state.resolveViewType()
        switch viewType {
        case .submitMusic:
            navigateToSelectMusic()
        case .humming:
            navigateToHumming()
        case .rehumming:
            navigateToRehumming()
        case .submitAnswer:
            navigateToSubmitAnswer()
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
        setupNavigationBar(for: vc)
    }
    
    private func navigateToSelectMusic() {
        let musicRepository = DIContainer.shared.resolve(MusicRepositoryProtocol.self)
        let playersRepository = DIContainer.shared.resolve(PlayersRepositoryProtocol.self)
        let answersRepository = DIContainer.shared.resolve(AnswersRepositoryProtocol.self)
        let gameStatusRepository = DIContainer.shared.resolve(GameStatusRepositoryProtocol.self)
        
        let vm = SelectMusicViewModel(
            musicRepository: musicRepository,
            playersRepository: playersRepository,
            answerRepository: answersRepository,
            gameStatusRepository: gameStatusRepository
        )
        let vc = SelectMusicViewController(selectMusicViewModel: vm)
        navigationController.pushViewController(vc, animated: true)
        setupNavigationBar(for: vc)
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
        let vc = HummingViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
        setupNavigationBar(for: vc)
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
        setupNavigationBar(for: vc)
    }
    
    private func navigateToSubmitAnswer() {
        let gameStatusRepository = DIContainer.shared.resolve(GameStatusRepositoryProtocol.self)
        let playersRepository = DIContainer.shared.resolve(PlayersRepositoryProtocol.self)
        let recordsRepository = DIContainer.shared.resolve(RecordsRepositoryProtocol.self)
        let submitsRepository = DIContainer.shared.resolve(SubmitsRepositoryProtocol.self)
        let musicRepository = DIContainer.shared.resolve(MusicRepositoryProtocol.self)
        
        let vm = SubmitAnswerViewModel(
            gameStatusRepository: gameStatusRepository,
            playersRepository: playersRepository,
            recordsRepository: recordsRepository,
            submitsRepository: submitsRepository,
            musicRepository: musicRepository
        )
        let vc = SubmitAnswerViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
        setupNavigationBar(for: vc)
    }
    
    private func navigateToResult() {
        let hummingResultRepository = DIContainer.shared.resolve(HummingResultRepositoryProtocol.self)
        let avatarRepository = DIContainer.shared.resolve(AvatarRepositoryProtocol.self)
        let gameStatusRepository = DIContainer.shared.resolve(GameStatusRepositoryProtocol.self)
        let playerRepository = DIContainer.shared.resolve(PlayersRepositoryProtocol.self)
        let roomActionRepository = DIContainer.shared.resolve(RoomActionRepositoryProtocol.self)
        let roomInfoRepository = DIContainer.shared.resolve(RoomInfoRepositoryProtocol.self)
        let musicRepository = DIContainer.shared.resolve(MusicRepositoryProtocol.self)
        let vm = HummingResultViewModel(
            hummingResultRepository: hummingResultRepository,
            avatarRepository: avatarRepository,
            gameStatusRepository: gameStatusRepository,
            playerRepository: playerRepository,
            roomActionRepository: roomActionRepository,
            roomInfoRepository: roomInfoRepository,
            musicRepository: musicRepository
        )
        let vc = HummingResultViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
        setupNavigationBar(for: vc)
    }
    
    private func navigationToWaiting() {}
    
//    private func leaveRoom() {
//        Task {
//            do {
//                try await roomActionRepository.leaveRoom()
//            } catch {
//                Logger.error(error.localizedDescription)
//            }
//        }
//    }
}
