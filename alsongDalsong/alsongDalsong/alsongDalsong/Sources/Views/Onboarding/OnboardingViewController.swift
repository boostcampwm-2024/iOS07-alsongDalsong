import UIKit
import SwiftUI
import Combine

final class OnboardingViewController: UIViewController {
    private var logoImageView = UIImageView(image: UIImage(named: Constants.logoImageName))
    private var createRoomButton = ASButton()
    private var joinRoomButton = ASButton()
    private var avatarView = ASAvatarCircleView()
    private var nickNameTextField = ASTextField()
    private var nickNamePanel = ASPanel()
    private var avatarRefreshButton = ASRefreshButton(size: 28)
    
    private var viewModel = OnboardingViewModel()
    private var cancleables = Set<AnyCancellable>()
    
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
        [createRoomButton, joinRoomButton, logoImageView, avatarView, nickNamePanel, nickNameTextField, avatarRefreshButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupLayout() {
        let safeArea = self.view.safeAreaLayoutGuide
        
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
                Task {
                    self?.createRoomButton.isEnabled = false
                    do {
                        if let nickname = self?.nickNameTextField.text, nickname.count > 0 {
                            self?.viewModel.setNickname(with: nickname)
                        }
                        try self?.viewModel.createRoom()
                    } catch {
                        //TODO: Error UI
                        self?.createRoomButton.isEnabled = true
                        print("error: \(error.localizedDescription)")
                    }
                    
                }
            },
            for: .touchUpInside)
        
        joinRoomButton.addAction(
            UIAction { [weak self] _ in
                let joinAlert = ASAlertController(
                    titleText: Constants.joinAlertTitle,
                    doneButtonTitle: Constants.doneAlertButtonTitle,
                    cancelButtonTitle: Constants.cancelAlertButtonTitle,
                    textFieldPlaceholder: Constants.roomNumberPlaceholder
                )
                joinAlert.doneButtonCompletion = { [weak self] in
                    Task {
                        do {
                            if let nickname = self?.nickNameTextField.text, nickname.count > 0 {
                                await self?.viewModel.setNickname(with: nickname)
                            }
                            try await self?.viewModel.joinRoom(roomNumber: joinAlert.text)
                        } catch {
                            //TODO: 에러 UI 띄우기
                            print("error: \(error.localizedDescription)")
                        }
                    }
                }
                self?.present(joinAlert, animated: true, completion: nil)
            },
            for: .touchUpInside)
        
        avatarRefreshButton.addAction(
            UIAction { [weak self] _ in
                self?.viewModel.refreshAvatars()
            }, for: .touchUpInside)
    }
    
    func setConfiguration() {
        createRoomButton.setConfiguration(systemImageName: "", title: Constants.craeteButtonTitle, backgroundColor: .asYellow)
        joinRoomButton.setConfiguration(systemImageName: "", title: Constants.joinButtonTitle, backgroundColor: .asMint)
        nickNamePanel.setConfiguration(title: Constants.nickNameTitle, titleAlign: .left, titleSize: 24)
    }
    
    private func bind() {
        viewModel.$nickname
            .receive(on: DispatchQueue.main)
            .sink { [weak self] nickname in
                self?.nickNameTextField.setConfiguration(placeholder: nickname)
            }
            .store(in: &cancleables)
        viewModel.$avatarURL
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] avatarURL in
                self?.avatarView.setImage(imageURL: avatarURL)
            }
            .store(in: &cancleables)
        viewModel.$roomNumber
            .filter { !$0.isEmpty }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] roomNumber in
                let lobbyViewController = UIHostingController(rootView: LobbyView(roomNumber: roomNumber))
                self?.navigationController?.pushViewController(lobbyViewController, animated: false)
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
