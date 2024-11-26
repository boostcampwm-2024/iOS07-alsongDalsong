import ASContainer
import ASRepository
import SwiftUI
import UIKit

class SelectMusicViewController: UIViewController {
    private var progressBar = ProgressBar()
    private var selectMusicView: UIHostingController<SelectMusicView>?
    private let selectCompleteButton = ASButton()
    
    private let selectMusicViewModel: SelectMusicViewModel
    
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
        progressBar.bind(to: selectMusicViewModel.$dueTime)
        selectCompleteButton.bind(to: selectMusicViewModel.$musicData)
    }
    
    func setupUI() {
        view.backgroundColor = .asLightGray
        selectCompleteButton.setConfiguration(title: "선택 완료", backgroundColor: .asGreen)
    }
    
    func setupLayout() {
        let musicView = SelectMusicView(viewModel: selectMusicViewModel)
        selectMusicView = UIHostingController(rootView: musicView)
        guard let selectMusicView = selectMusicView else { return }
        
        view.addSubview(progressBar)
        view.addSubview(selectMusicView.view)
        view.addSubview(selectCompleteButton)
        
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        selectMusicView.view.translatesAutoresizingMaskIntoConstraints = false
        selectCompleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        let safeArea = view.safeAreaLayoutGuide
    
        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 16),
            
            selectMusicView.view.topAnchor.constraint(equalTo: progressBar.bottomAnchor),
            selectMusicView.view.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            selectMusicView.view.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            selectMusicView.view.bottomAnchor.constraint(equalTo: selectCompleteButton.topAnchor, constant: -20),
            
            selectCompleteButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 24),
            selectCompleteButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -24),
            selectCompleteButton.heightAnchor.constraint(equalToConstant: 64),
            selectCompleteButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -25)
        ])
    }
    
    func setAction() {
        selectCompleteButton.addAction(UIAction { [weak self] _ in
            self?.selectMusicViewModel.submitMusic()
            self?.selectMusicViewModel.stopMusic()
            let gameStatusRepository = DIContainer.shared.resolve(GameStatusRepositoryProtocol.self)
            let playersRepository = DIContainer.shared.resolve(PlayersRepositoryProtocol.self)
            let musicRepository = DIContainer.shared.resolve(MusicRepositoryProtocol.self)
            let answersRepository = DIContainer.shared.resolve(AnswersRepositoryProtocol.self)
            let submitsRepository = DIContainer.shared.resolve(SubmitsRepositoryProtocol.self)
            
            let hummingViewModel = HummingViewModel(
                gameStatusRepository: gameStatusRepository,
                playersRepository: playersRepository,
                answersRepository: answersRepository,
                submitsRepository: submitsRepository
            )
            
            self?.navigationController?.pushViewController(HummingViewController(vm: hummingViewModel), animated: true)
        }, for: .touchUpInside)
        selectCompleteButton.isEnabled = false
    }
}
