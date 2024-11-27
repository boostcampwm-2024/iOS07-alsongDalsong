import ASContainer
import ASRepository
import SwiftUI
import UIKit

class SelectMusicViewController: UIViewController {
    private var progressBar = ProgressBar()
    private var selectMusicView: UIHostingController<SelectMusicView>?
    private let selectCompleteButton = ASButton()
    
    private let viewModel: SelectMusicViewModel
    
    init(selectMusicViewModel: SelectMusicViewModel) {
        self.viewModel = selectMusicViewModel
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
    
    func showSubmitLoading() {
        let alert = ASAlertController(progressText: .submitMusic) { [weak self] in
            await self?.viewModel.submitMusic()
        }
        presentLoadingView(alert)
    }
    
    private func bindToComponents() {
        progressBar.bind(to: viewModel.$dueTime)
        selectCompleteButton.bind(to: viewModel.$musicData)
    }
    
    func setupUI() {
        view.backgroundColor = .asLightGray
        selectCompleteButton.setConfiguration(title: "선택 완료", backgroundColor: .asGreen)
        selectCompleteButton.isEnabled = false
    }
    
    func setupLayout() {
        let musicView = SelectMusicView(viewModel: viewModel)
        selectMusicView = UIHostingController(rootView: musicView)
        guard let selectMusicView else { return }
        
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
            self?.selectCompleteButton.updateButton(.complete)
            self?.selectCompleteButton.updateButton(.disabled)
            self?.showSubmitLoading()
            self?.viewModel.stopMusic()
            self?.progressBar.cancelCompletion()
        }, for: .touchUpInside)
        
        progressBar.setCompletionHandler { [weak self] in
            self?.showSubmitLoading()
        }
    }
}
