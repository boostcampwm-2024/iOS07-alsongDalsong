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
    private var nickNameTextField = ASTextField()
    private var nickNamePanel = ASPanel()
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
        self.inviteCode = ""
        self.viewmodel = nil
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        setAction()
        setConfiguration()
        bind()
    }
    
    private func setupUI() {
        view.backgroundColor = .asLightGray
        for item in [createRoomButton, joinRoomButton, logoImageView, avatarView, nickNamePanel, nickNameTextField, avatarRefreshButton] {
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
            joinRoomButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 24),
            joinRoomButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -24),
            joinRoomButton.heightAnchor.constraint(equalToConstant: 64),
            joinRoomButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -25),
            
            createRoomButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 24),
            createRoomButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -24),
            createRoomButton.heightAnchor.constraint(equalToConstant: 64),
            createRoomButton.bottomAnchor.constraint(equalTo: joinRoomButton.topAnchor, constant: -25),
            
            logoImageView.widthAnchor.constraint(equalToConstant: 355),
            logoImageView.heightAnchor.constraint(equalToConstant: 161),
            logoImageView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            logoImageView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 50),
            
            avatarView.widthAnchor.constraint(equalToConstant: 200),
            avatarView.heightAnchor.constraint(equalToConstant: 200),
            avatarView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            avatarView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 0),
            
            nickNamePanel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 24),
            nickNamePanel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -24),
            nickNamePanel.heightAnchor.constraint(equalToConstant: 100),
            nickNamePanel.bottomAnchor.constraint(equalTo: createRoomButton.topAnchor, constant: -25),
            
            nickNameTextField.leadingAnchor.constraint(equalTo: nickNamePanel.leadingAnchor, constant: 16),
            nickNameTextField.trailingAnchor.constraint(equalTo: nickNamePanel.trailingAnchor, constant: -16),
            nickNameTextField.bottomAnchor.constraint(equalTo: nickNamePanel.bottomAnchor, constant: -16),
            
            avatarRefreshButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 231),
            avatarRefreshButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 352),
            avatarRefreshButton.widthAnchor.constraint(equalToConstant: 60),
            avatarRefreshButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    /// 화면상의 컴포넌트들에게 Action을 추가함
    private func setAction() {
        createRoomButton.addAction(
            UIAction { [weak self] _ in
                if let nickname = self?.nickNameTextField.text, nickname.count > 0 {
                    self?.viewmodel?.setNickname(with: nickname)
                }
                self?.viewmodel?.createRoom()
            },
            for: .touchUpInside)
        
        if inviteCode.isEmpty {
            joinRoomButton.addAction(
                UIAction { [weak self] _ in
                    let joinAlert = ASAlertController(
                        titleText: Constants.joinAlertTitle,
                        doneButtonTitle: Constants.doneAlertButtonTitle,
                        cancelButtonTitle: Constants.cancelAlertButtonTitle,
                        textFieldPlaceholder: Constants.roomNumberPlaceholder)
                    
                    joinAlert.doneButtonCompletion = { [weak self] in
                        if let nickname = self?.nickNameTextField.text, nickname.count > 0 {
                            self?.viewmodel?.setNickname(with: nickname)
                        }
                        self?.viewmodel?.joinRoom(roomNumber: joinAlert.text)
                    }
                    self?.present(joinAlert, animated: true, completion: nil)
                },
                for: .touchUpInside)
        } else {
            joinRoomButton.addAction(UIAction { [weak self] _ in
                if let nickname = self?.nickNameTextField.text, nickname.count > 0 {
                    self?.viewmodel?.setNickname(with: nickname)
                }
                guard let roomNumber = self?.inviteCode else { return }
                self?.viewmodel?.joinRoom(roomNumber: roomNumber)
                
            }, for: .touchUpInside)
        }
        
        avatarRefreshButton.addAction(
            UIAction { [weak self] _ in
                self?.viewmodel?.refreshAvatars()
            }, for: .touchUpInside)
    }
    
    func setConfiguration() {
        createRoomButton.setConfiguration(
            systemImageName: "",
            title: Constants.craeteButtonTitle,
            backgroundColor: .asYellow)
        joinRoomButton.setConfiguration(
            systemImageName: "",
            title: Constants.joinButtonTitle,
            backgroundColor: .asMint)
        nickNamePanel.setConfiguration(
            title: Constants.nickNameTitle,
            titleAlign: .left,
            titleSize: 24)
    }
    
    private func bind() {
        viewmodel?.$nickname
            .receive(on: DispatchQueue.main)
            .sink { [weak self] nickname in
                self?.nickNameTextField.setConfiguration(placeholder: nickname)
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
                let avatarRepository = DIContainer.shared.resolve(AvatarRepositoryProtocol.self)
                
                mainRepository.connectRoom(roomNumber: roomNumber)
                let lobbyViewModel = LobbyViewModel(
                    playersRepository: playersRepository,
                    roomInfoRepository: roomInfoRepository,
                    avatarRepository: avatarRepository
                )
                let lobbyView = LobbyView(viewModel: lobbyViewModel)
                let lobbyViewController = UIHostingController(rootView: lobbyView)
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
    }
}

extension OnboardingViewController {
    enum Constants {
        static let craeteButtonTitle = "방 생성하기!"
        static let joinButtonTitle = "방 참가하기!"
        static let joinAlertTitle = "게임 입장 코드를 입력하세요"
        static let nickNameTitle = "닉네임"
        static let doneAlertButtonTitle = "완료"
        static let cancelAlertButtonTitle = "취소"
        static let roomNumberPlaceholder = "000000"
        static let logoImageName = "logo"
    }
}
