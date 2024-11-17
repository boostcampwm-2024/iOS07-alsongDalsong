import UIKit

final class OnboardingViewController: UIViewController {
    private var logoImageView = UIImageView(image: UIImage(named: Constants.logoImageName))
    private var createRoomButton = ASButton(title: Constants.craeteButtonTitle, backgroundColor: .asYellow)
    private var joinRoomButton = ASButton(title: Constants.joinButtonTitle, backgroundColor: .asMint)
    private var avatarView = ASAvatarCircleView(image: UIImage(named: "mojojojo") ?? UIImage.fake)
    private var nickNameTextField = ASTextField(placeholder: "도덕적인 삶")
    private var nickNamePanel = ASPanel(title: Constants.nickNameTitle, titleAlign: .left, titleSize: 24)
    private var nickNameRefreshButton = ASRefreshButton(size: 28)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        setAction()
    }
    
    private func setupUI() {
        view.backgroundColor = .asLightGray
        [createRoomButton, joinRoomButton, logoImageView, avatarView, nickNamePanel, nickNameTextField, nickNameRefreshButton].forEach {
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
            
            nickNameRefreshButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 231),
            nickNameRefreshButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 352),
            nickNameRefreshButton.widthAnchor.constraint(equalToConstant: 60),
            nickNameRefreshButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
    }
    
    /// 화면상의 컴포넌트 들에게 Action을 추가함
    private func setAction() {
        joinRoomButton.addAction(
            UIAction { [weak self] _ in
                let joinAlert = ASAlertController(
                    titleText: Constants.joinAlertTitle,
                    doneButtonTitle: Constants.doneAlertButtonTitle,
                    cancelButtonTitle: Constants.cancelAlertButtonTitle,
                    textFieldPlaceholder: Constants.roomNumberPlaceholder
                )
                joinAlert.doneButtonCompletion = { [weak self] in
                    // TODO: 방 참가 로직 추가
                    print("입력된 텍스트: \(joinAlert.text)")
                }
                self?.present(joinAlert, animated: true, completion: nil)
            },
            for: .touchUpInside)
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
        static let roomNumberPlaceholder = "#000000"
        
        static let logoImageName = "logo"
    }
}
