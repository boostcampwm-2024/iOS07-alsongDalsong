import ASContainer
import ASRepository
import SwiftUI
import UIKit

final class LobbyViewController: UIViewController {
    let inviteButton = ASButton()
    let startButton = ASButton()
    
    let viewmodel: LobbyViewModel
    
    init(lobbyViewModel: LobbyViewModel) {
        self.viewmodel = lobbyViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        setAction()
    }
    
    private func setupUI() {
        view.backgroundColor = .asLightGray
        inviteButton.setConfiguration(systemImageName: "link", title: "초대하기!", backgroundColor: .asYellow)
        inviteButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.setConfiguration(systemImageName: "play.fill", title: "시작하기!", backgroundColor: .asMint)
        startButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setAction() {
        inviteButton.addAction(UIAction { [weak self] _ in
            guard let roomNumber = self?.viewmodel.roomNumber else { return }
            if let url = URL(string: "alsongDalsong://invite/?roomnumber=\(roomNumber)") {
                let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self?.inviteButton
                self?.present(activityViewController, animated: true, completion: nil)
            }
        }, for: .touchUpInside)
        
        startButton.addAction(UIAction { [weak self] _ in
            let musicRepository = DIContainer.shared.resolve(MusicRepositoryProtocol.self)
            let selectMusicViewModel = SelectMusicViewModel(musicRepository: musicRepository)
            let selectMusicViewController = SelectMusicViewController(selectMusicViewModel: selectMusicViewModel)
            self?.navigationController?.pushViewController(selectMusicViewController, animated: true)
        }, for: .touchUpInside)
    }
    
    private func setupLayout() {
        let lobbyView = UIHostingController(rootView: LobbyView(viewModel: viewmodel))
        lobbyView.didMove(toParent: self)
        lobbyView.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(lobbyView)
        view.addSubview(lobbyView.view)
        view.addSubview(startButton)
        view.addSubview(inviteButton)
        
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            lobbyView.view.topAnchor.constraint(equalTo: safeArea.topAnchor),
            lobbyView.view.bottomAnchor.constraint(equalTo: inviteButton.topAnchor, constant: -20),
            lobbyView.view.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            lobbyView.view.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            
            inviteButton.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -25),
            inviteButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 24),
            inviteButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -24),
            inviteButton.heightAnchor.constraint(equalToConstant: 64),
            
            startButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -25),
            startButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 24),
            startButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -24),
            startButton.heightAnchor.constraint(equalToConstant: 64)
        ])
    }
}
