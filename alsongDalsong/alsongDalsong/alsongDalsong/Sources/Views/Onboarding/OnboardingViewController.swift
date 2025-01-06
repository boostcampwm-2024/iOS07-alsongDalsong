import ASContainer
import ASRepositoryProtocol
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
    private var gameNavigationController: GameNavigationController?
    private var cancellables = Set<AnyCancellable>()
    var shouldMoveKeyboard: Bool = true

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
        viewModel?.authorizeAppleMusic()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeKeyboard()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
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
        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalToConstant: 356),
            logoImageView.heightAnchor.constraint(equalToConstant: 160),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48),

            avatarView.widthAnchor.constraint(equalToConstant: 200),
            avatarView.heightAnchor.constraint(equalToConstant: 200),
            avatarView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            avatarRefreshButton.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: -56),
            avatarRefreshButton.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: -56),
            avatarRefreshButton.widthAnchor.constraint(equalToConstant: 60),
            avatarRefreshButton.heightAnchor.constraint(equalToConstant: 60),

            nickNamePanel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 36),
            nickNamePanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            nickNamePanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            nickNamePanel.heightAnchor.constraint(equalToConstant: 100),

            createRoomButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            createRoomButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            createRoomButton.topAnchor.constraint(equalTo: nickNamePanel.bottomAnchor, constant: 24),
            createRoomButton.bottomAnchor.constraint(equalTo: joinRoomButton.topAnchor, constant: -24),
            createRoomButton.heightAnchor.constraint(equalToConstant: 64),

            joinRoomButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            joinRoomButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            joinRoomButton.heightAnchor.constraint(equalToConstant: 64),
            joinRoomButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
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
            text: Constants.craeteButtonTitle,
            backgroundColor: .asYellow
        )
        joinRoomButton.setConfiguration(
            systemImageName: "",
            text: Constants.joinButtonTitle,
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
        let mainRepository: MainRepositoryProtocol = DIContainer.shared.resolve(MainRepositoryProtocol.self)
        mainRepository.connectRoom(roomNumber: roomNumber)
        let gameStateRepository = DIContainer.shared.resolve(GameStateRepositoryProtocol.self)
        let roomActionRepository = DIContainer.shared.resolve(RoomActionRepositoryProtocol.self)
        guard let navigationController else { return }

        gameNavigationController = GameNavigationController(
            navigationController: navigationController,
            gameStateRepository: gameStateRepository,
            roomActionRepository: roomActionRepository,
            roomNumber: roomNumber
        )

        gameNavigationController?.setConfiguration()
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
            do {
                let number = try await viewModel?.joinRoom(roomNumber: roomNumber)
                guard let number, !number.isEmpty else { return }
                navigateToLobby(with: number)
            } catch {
                showRoomFailedAlert(error)
            }
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

    private func setNicknameAndCreateRoom() async throws {
        if let nickname = nickNamePanel.text, !nickname.isEmpty {
            viewModel?.setNickname(with: nickname)
        }
        do {
            let number = try await viewModel?.createRoom()
            guard let number else { return }
            navigateToLobby(with: number)
        } catch {
            throw error
        }
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
    private func showRoomNumerInputAlert() {
        shouldMoveKeyboard = false
        let alert = InputAlertController(
            titleText: .joinRoom,
            textFieldPlaceholder: .roomNumber,
            isUppercased: true
        ) { [weak self] roomNumber in
            self?.setNicknameAndJoinRoom(with: roomNumber)
            self?.shouldMoveKeyboard = true
        } secondaryButtonAction: {
            self.shouldMoveKeyboard = true
        }

        presentAlert(alert)
    }

    private func showRoomFailedAlert(_ error: Error) {
        let alert = SingleButtonAlertController(titleText: .error(error))
        presentAlert(alert)
    }

    private func showCreateRoomLoading() {
        let alert = LoadingAlertController(
            progressText: .joinRoom,
            loadAction: { [weak self] in
                try await self?.setNicknameAndCreateRoom()
            },
            errorCompletion: { [weak self] error in
                self?.showRoomFailedAlert(error)
            }
        )
        presentAlert(alert)
    }
}

// MARK: - KeyboardObserve

private extension OnboardingViewController {
    private func observeKeyboard() {
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

    func hideKeyboard() {
        view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(
                    OnboardingViewController.dismissKeyboard
                )
            )
        )
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func keyboardWillShow(_ notification: NSNotification) {
        guard shouldMoveKeyboard else { return }
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height

            UIView.animate(withDuration: 0.3) {
                self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
            }
        }
    }

    @objc func keyboardWillHide(_ notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.view.transform = .identity
        }
    }

    @objc func appDidEnterBackground(_ notification: NSNotification) {
        view.endEditing(true)
    }
}
