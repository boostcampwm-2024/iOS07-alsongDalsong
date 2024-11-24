import ASContainer
import ASRepository
import SwiftUI
import UIKit

class SelectMusicViewController: UIViewController {
    let selectMusicViewModel: SelectMusicViewModel
    let selectCompleteButton = ASButton()
    
    init(selectMusicViewModel: SelectMusicViewModel) {
        self.selectMusicViewModel = selectMusicViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAction()
        setupUI()
        setupLayout()
        bindToComponents()
    }
    
    private func bindToComponents() {
        selectCompleteButton.bind(to: selectMusicViewModel.$musicData)
    }
    
    func setupUI() {
        view.backgroundColor = .asLightGray
    }
    
    func setupLayout() {
        let selectMusicView = SelectMusicView(viewModel: selectMusicViewModel)
        let hostingController = UIHostingController(rootView: selectMusicView)
        addChild(hostingController)
        
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(selectCompleteButton)
        selectCompleteButton.translatesAutoresizingMaskIntoConstraints = false
        selectCompleteButton.setConfiguration(title: "선택 완료", backgroundColor: .asGreen)
        let safeArea = view.safeAreaLayoutGuide
    
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: safeArea.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: selectCompleteButton.topAnchor, constant: -20),
            
            selectCompleteButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 24),
            selectCompleteButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -24),
            selectCompleteButton.heightAnchor.constraint(equalToConstant: 64),
            selectCompleteButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -25)
        ])
    }
    
    func setAction() {
        selectCompleteButton.addAction(UIAction { [weak self] _ in
            self?.selectMusicViewModel.stopMusic()
            let gameStatusRepository = DIContainer.shared.resolve(GameStatusRepositoryProtocol.self)
            let playersRepository = DIContainer.shared.resolve(PlayersRepositoryProtocol.self)
            let submitsRepository = DIContainer.shared.resolve(SubmitsRepositoryProtocol.self)
            
            let hummingViewModel = HummingViewModel(
                gameStatusRepository: gameStatusRepository,
                playersRepository: playersRepository,
                submitsRepository: submitsRepository
            )
            
            self?.navigationController?.pushViewController(HummingViewController(vm: hummingViewModel), animated: true)
        }, for: .touchUpInside)
        selectCompleteButton.isEnabled = false
    }
}
