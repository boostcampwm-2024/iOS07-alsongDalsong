import ASContainer
import ASRepository
import Combine
import UIKit

final class OnboardingViewController: UIViewController {
    private var logoImageView = UIImageView(image: UIImage(named: Constants.logoImageName))
    private var createRoomButton = ASButton()
    private var joinRoomButton = ASButton()
    private var avatarView = ASAvatarCircleView()
    private var nickNamePanel = NicknamePanel()
    private var avatarRefreshButton = ASRefreshButton(size: 28)
    private var viewModel: OnboardingViewModel?
    private var inviteCode: String
    private var cancellables = Set<AnyCancellable>()

    init(viewmodel: OnboardingViewModel, inviteCode: String) {
        viewModel = viewmodel
        self.inviteCode = inviteCode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        inviteCode = ""
        viewModel = nil
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        setAction()
        setupButton()
        hideKeyboard()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeKeyboard()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    private func setupUI() {
        view.backgroundColor = .asLightGray
        for item in [createRoomButton, joinRoomButton, logoImageView, avatarView, nickNamePanel, avatarRefreshButton] {
            view.addSubview(item)
            item.translatesAutoresizingMaskIntoConstraints = false
        }

        if !inviteCode.isEmpty {
            createRoomButton.isHidden = true
        }
    }

    private func setupLayout() {
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalToConstant: 355),
            logoImageView.heightAnchor.constraint(equalToConstant: 161),
            logoImageView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            logoImageView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 50),

            avatarView.widthAnchor.constraint(equalToConstant: 200),
            avatarView.heightAnchor.constraint(equalToConstant: 200),
            avatarView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),

            avatarRefreshButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 231),
            avatarRefreshButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 352),
            avatarRefreshButton.widthAnchor.constraint(equalToConstant: 60),
            avatarRefreshButton.heightAnchor.constraint(equalToConstant: 60),

            nickNamePanel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 36),
            nickNamePanel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 24),
            nickNamePanel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -24),
            nickNamePanel.heightAnchor.constraint(equalToConstant: 100),

            createRoomButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 24),
            createRoomButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -24),
            createRoomButton.topAnchor.constraint(equalTo: nickNamePanel.bottomAnchor, constant: 24),
            createRoomButton.bottomAnchor.constraint(equalTo: joinRoomButton.topAnchor, constant: -24),
            createRoomButton.heightAnchor.constraint(equalToConstant: 64),

            joinRoomButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 24),
            joinRoomButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -24),
            joinRoomButton.heightAnchor.constraint(equalToConstant: 64),
            joinRoomButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -24),
        ])
    }

    private func setAction() {
        createRoomButton.addAction(
            UIAction { [weak self] _ in
                self?.showCreateRoomLoading()
            },
            for: .touchUpInside
        )

        joinRoomButton.addAction(
            UIAction { [weak self] _ in
                guard let inviteCode = self?.inviteCode else { return }
                inviteCode.isEmpty ?
                    self?.showRoomNumerInputAlert() : self?.autoJoinRoom()
            },
            for: .touchUpInside
        )

        avatarRefreshButton.addAction(
            UIAction { [weak self] _ in
                self?.viewModel?.refreshAvatars()
            }, for: .touchUpInside
        )
    }

    private func setupButton() {
        createRoomButton.setConfiguration(
            systemImageName: "",
            title: Constants.craeteButtonTitle,
            backgroundColor: .asYellow
        )
        joinRoomButton.setConfiguration(
            systemImageName: "",
            title: Constants.joinButtonTitle,
            backgroundColor: .asMint
        )
    }

    private func bindViewModel() {
        bind(viewModel?.$nickname) { [weak self] nickname in
            self?.nickNamePanel.updateTextField(placeholder: nickname)
        }

        bind(viewModel?.$avatarData) { [weak self] data in
            self?.avatarView.setImage(imageData: data)
        }

        bind(viewModel?.$buttonEnabled) { [weak self] enabled in
            self?.createRoomButton.isEnabled = enabled
            self?.joinRoomButton.isEnabled = enabled
        }
    }

    private func navigateToLobby(with roomNumber: String) {
        let mainRepository = DIContainer.shared.resolve(MainRepositoryProtocol.self)
        let playersRepository = DIContainer.shared.resolve(PlayersRepositoryProtocol.self)
        let roomInfoRepository = DIContainer.shared.resolve(RoomInfoRepositoryProtocol.self)
        let roomActionRepository = DIContainer.shared.resolve(RoomActionRepositoryProtocol.self)
        let avatarRepository = DIContainer.shared.resolve(AvatarRepositoryProtocol.self)

        mainRepository.connectRoom(roomNumber: roomNumber)
        let lobbyViewModel = LobbyViewModel(
            playersRepository: playersRepository,
            roomInfoRepository: roomInfoRepository,
            roomActionRepository: roomActionRepository,
            avatarRepository: avatarRepository
        )
        let lobbyViewController = LobbyViewController(lobbyViewModel: lobbyViewModel)
        navigationController?.pushViewController(lobbyViewController, animated: false)
    }

    private func bind<T>(
        _ publisher: Published<T>.Publisher?,
        handler: @escaping (T) -> Void
    ) {
        publisher?
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: handler)
            .store(in: &cancellables)
    }

    private func joinRoom(with roomNumber: String) {
        Task {
            guard let number = await viewModel?.joinRoom(roomNumber: roomNumber),
                  !number.isEmpty
            else {
                if createRoomButton.isHidden {
                    createRoomButton.isHidden = true
                }
                showJoinRoomFailedAlert()
                return
            }
            inviteCode = ""
            navigateToLobby(with: number)
        }
    }

    private func autoJoinRoom() {
        if let nickname = nickNamePanel.text, !nickname.isEmpty {
            viewModel?.setNickname(with: nickname)
        }
        joinRoom(with: inviteCode)
    }
    
    private func setNicknameAndJoinRoom(with roomNumber: String) {
        if let nickname = nickNamePanel.text, !nickname.isEmpty {
            viewModel?.setNickname(with: nickname)
        }
        joinRoom(with: roomNumber)
    }

    private func setNicknameAndCreateRoom() async {
        if let nickname = nickNamePanel.text, !nickname.isEmpty {
            viewModel?.setNickname(with: nickname)
        }

        guard let number = await viewModel?.createRoom() else { return }
        if number.isEmpty { showCreateRoomFailedAlert() }
        else { navigateToLobby(with: number) }
    }
}

extension OnboardingViewController {
    enum Constants {
        static let craeteButtonTitle = "방 생성하기!"
        static let joinButtonTitle = "방 참가하기!"
        static let logoImageName = "logo"
    }
}

// MARK: - Alert

extension OnboardingViewController {
    func showRoomNumerInputAlert() {
        let alert = ASAlertController(
            titleText: .joinRoom,
            textFieldPlaceholder: .roomNumber,
            isUppercased: true
        ) { [weak self] roomNumber in
            self?.setNicknameAndJoinRoom(with: roomNumber)
        }
        presentAlert(alert)
    }

    func showJoinRoomFailedAlert() {
        let alert = ASAlertController(titleText: .joinFailed)
        presentAlert(alert)
    }

    func showCreateRoomFailedAlert() {
        let alert = ASAlertController(titleText: .createFailed)
        presentAlert(alert)
    }
    
    func showCreateRoomLoading() {
        let alert = ASAlertController(progressText: .joinRoom) { [weak self] in
            await self?.setNicknameAndCreateRoom()
        }
        presentLoadingView(alert)
    }
}

// MARK: - KeyboardObserve

private extension OnboardingViewController {
    func observeKeyboard() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground(_:)),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }
}
