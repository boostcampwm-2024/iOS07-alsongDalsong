import UIKit

class ViewController: UIViewController {
    private var logoImageView: UIImageView!
    private var createRoomButton: ASButton!
    private var joinRoomButton: ASButton!
    private var avatarView: ASAvatarCircleView!
    private var nickNameTextField: ASTextField!
    private var nickNamePanel: ASPanel!
    private var avatarRefreshButton: ASRefreshButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .asLightGray
        
        setupUI()
        setupLayout()
    }
    
    private func setupUI() {
        //현재는 하드코딩으로 들어가지만 이런 문구들을 모아놓는 다른 파일이 있으면 좋을 것 같음 (혹시나 모를 외국어 지원 등...)
        createRoomButton = ASButton(title: "방 생성하기!", backgroundColor: .asYellow)
        self.view.addSubview(createRoomButton)
        
        joinRoomButton = ASButton(title: "방 참가하기!", backgroundColor: .asMint)
        self.view.addSubview(joinRoomButton)
        
        logoImageView = UIImageView(image: UIImage(named: "logo"))
        self.view.addSubview(logoImageView)
        
        avatarView = ASAvatarCircleView(image: UIImage(named: "mojojojo") ?? UIImage.fake)
        self.view.addSubview(avatarView)
        
        nickNamePanel = ASPanel(title: "닉네임", titleAlign: .left, titleSize: 24)
        self.view.addSubview(nickNamePanel)
        
        //placeholder는 추후 랜덤 생성된 닉네임으로 바뀌어야 함
        nickNameTextField = ASTextField(placeholder: "도덕적인 삶")
        nickNamePanel.addSubview(nickNameTextField)
        
        avatarRefreshButton = ASRefreshButton(size: 28)
        self.view.addSubview(avatarRefreshButton)
    }
    
    private func setupLayout() {
        let safeArea = self.view.safeAreaLayoutGuide
        createRoomButton.translatesAutoresizingMaskIntoConstraints = false
        joinRoomButton.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        nickNamePanel.translatesAutoresizingMaskIntoConstraints = false
        nickNameTextField.translatesAutoresizingMaskIntoConstraints = false
        avatarRefreshButton.translatesAutoresizingMaskIntoConstraints = false
        
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
}
