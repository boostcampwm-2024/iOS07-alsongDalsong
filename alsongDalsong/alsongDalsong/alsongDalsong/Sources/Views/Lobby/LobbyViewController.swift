import ASContainer
import ASRepository
import SwiftUI
import UIKit

final class LobbyViewController: UIViewController {
    let startButton = ASButton()
    
    let lobbyViewModel: LobbyViewModel!
    
    init(lobbyViewModel: LobbyViewModel) {
        self.lobbyViewModel = lobbyViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.lobbyViewModel = nil
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupUI()
        setAction()
    }
    
    private func setupUI() {
        view.backgroundColor = .asLightGray
        startButton.setConfiguration(systemImageName: "play.fill", title: "시작하기!", backgroundColor: .asMint)
        view.backgroundColor = .asLightGray
        startButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setAction() {
        startButton.addAction(UIAction { [weak self] _ in
            let musicRepository = DIContainer.shared.resolve(MusicRepositoryProtocol.self)
            let selectMusicViewModel = SelectMusicViewModel(musicRepository: musicRepository)
            let selectMusicViewController = SelectMusicViewController(selectMusicViewModel: selectMusicViewModel)
            self?.navigationController?.pushViewController(selectMusicViewController, animated: true)
        }, for: .touchUpInside)
    }
    
    private func setupLayout() {
        let lobbyView = UIHostingController(rootView: LobbyView(viewModel: lobbyViewModel))
        addChild(lobbyView)
        view.addSubview(lobbyView.view)
        view.addSubview(startButton)
        lobbyView.didMove(toParent: self)
        lobbyView.view.translatesAutoresizingMaskIntoConstraints = false
        
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            lobbyView.view.topAnchor.constraint(equalTo: safeArea.topAnchor),
            lobbyView.view.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -20),
            lobbyView.view.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            lobbyView.view.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            
            startButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -25),
            startButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 24),
            startButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -24),
            startButton.heightAnchor.constraint(equalToConstant: 64)
        ])
    }
}
