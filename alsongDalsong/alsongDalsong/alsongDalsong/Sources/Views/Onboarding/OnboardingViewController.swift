import ASContainer
import ASRepository
import Combine
import SwiftUI
import UIKit

final class OnboardingViewController: UIViewController {
    private var logoImageView = UIImageView(image: UIImage(named: Constants.logoImageName))
    private var createRoomButton = ASButton()
    private var joinRoomButton = ASButton()
    private var avatarView = ASAvatarCircleView()
    private var nickNamePanel = NicknamePanel()
    private var avatarRefreshButton = ASRefreshButton(size: 28)
    private var viewmodel: OnboardingViewModel?
    private var inviteCode: String
    private var cancleables = Set<AnyCancellable>()

    init(viewmodel: OnboardingViewModel, inviteCode: String) {
        self.viewmodel = viewmodel
        self.inviteCode = inviteCode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        inviteCode = ""
        viewmodel = nil
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        setAction()
        setConfiguration()
        hideKeyboard()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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

    /// 화면상의 컴포넌트들에게 Action을 추가함
    private func setAction() {
        createRoomButton.addAction(
            UIAction { [weak self] _ in
                if let nickname = self?.nickNamePanel.text, !nickname.isEmpty {
                    self?.viewmodel?.setNickname(with: nickname)
                }
                self?.viewmodel?.createRoom()
            },
            for: .touchUpInside
        )

        if inviteCode.isEmpty {
            joinRoomButton.addAction(
                UIAction { [weak self] _ in
//                    let joinAlert = ASAlertController(.load)
                    let joinAlert = ASAlertController(
                        titleText: .joinRoom,
                        textFieldPlaceholder: .roomNumber,
                        isUppercased: true
                    ) { [weak self] roomNumber in
                        if let nickname = self?.nickNamePanel.text, !nickname.isEmpty {
                            self?.viewmodel?.setNickname(with: nickname)
                        }
                        self?.viewmodel?.joinRoom(roomNumber: roomNumber)
                    }
                    self?.present(joinAlert, animated: true, completion: nil)
                },
                for: .touchUpInside
            )
        } else {
            joinRoomButton.addAction(UIAction { [weak self] _ in
                if let nickname = self?.nickNamePanel.text, nickname.count > 0 {
                    self?.viewmodel?.setNickname(with: nickname)
                }
                guard let roomNumber = self?.inviteCode else { return }
                self?.viewmodel?.joinRoom(roomNumber: roomNumber)

            }, for: .touchUpInside)
        }

        avatarRefreshButton.addAction(
            UIAction { [weak self] _ in
                self?.viewmodel?.refreshAvatars()
            }, for: .touchUpInside
        )
    }

    func setConfiguration() {
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

    private func bind() {
        viewmodel?.$nickname
            .receive(on: DispatchQueue.main)
            .sink { [weak self] nickname in
                self?.nickNamePanel.updateTextField(placeholder: nickname)
            }
            .store(in: &cancleables)
        viewmodel?.$avatarData
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] data in
                self?.avatarView.setImage(imageData: data)
            }
            .store(in: &cancleables)
        viewmodel?.$roomNumber
            .filter { !$0.isEmpty }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] roomNumber in
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
                self?.navigationController?.pushViewController(lobbyViewController, animated: false)
            }
            .store(in: &cancleables)
        viewmodel?.$buttonEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] enabled in
                self?.createRoomButton.isEnabled = enabled
                self?.joinRoomButton.isEnabled = enabled
            }
            .store(in: &cancleables)

        viewmodel?.$joinResponse
            .receive(on: DispatchQueue.main)
            .sink { [weak self] success in
                if !success {
                    self?.createRoomButton.isHidden = false
                    let joinFailedAlert = ASAlertController(
                        titleText: .joinFailed
                    )
                    self?.present(joinFailedAlert, animated: true, completion: nil)
                }
            }
            .store(in: &cancleables)
    }
}

extension OnboardingViewController {
    enum Constants {
        static let craeteButtonTitle = "방 생성하기!"
        static let joinButtonTitle = "방 참가하기!"
        static let logoImageName = "logo"
    }
}
