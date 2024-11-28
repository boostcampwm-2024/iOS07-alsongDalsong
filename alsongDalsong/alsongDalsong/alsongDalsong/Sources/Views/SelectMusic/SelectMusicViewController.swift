import ASContainer
import ASRepository
import SwiftUI
import UIKit

class SelectMusicViewController: UIViewController {
    private var progressBar = ProgressBar()
    private var selectMusicView: UIHostingController<SelectMusicView>?
    private let submitButton = ASButton()
    
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
    
    private func bindToComponents() {
        progressBar.bind(to: viewModel.$dueTime)
        submitButton.bind(to: viewModel.$musicData)
    }
    
    private func setupUI() {
        view.backgroundColor = .asLightGray
        submitButton.setConfiguration(title: "선택 완료", backgroundColor: .asGreen)
        submitButton.isEnabled = false
    }
    
    private func setupLayout() {
        let musicView = SelectMusicView(viewModel: viewModel)
        selectMusicView = UIHostingController(rootView: musicView)
        guard let selectMusicView else { return }
        
        view.addSubview(progressBar)
        view.addSubview(selectMusicView.view)
        view.addSubview(submitButton)
        
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        selectMusicView.view.translatesAutoresizingMaskIntoConstraints = false
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        
        let safeArea = view.safeAreaLayoutGuide
    
        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 16),
            
            selectMusicView.view.topAnchor.constraint(equalTo: progressBar.bottomAnchor),
            selectMusicView.view.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            selectMusicView.view.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            selectMusicView.view.bottomAnchor.constraint(equalTo: submitButton.topAnchor, constant: -20),
            
            submitButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 24),
            submitButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -24),
            submitButton.heightAnchor.constraint(equalToConstant: 64),
            submitButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -25)
        ])
    }
    
    private func setAction() {
        submitButton.addAction(UIAction { [weak self] _ in
            self?.showSubmitMusicLoading()
        }, for: .touchUpInside)
        
        progressBar.setCompletionHandler { [weak self] in
            self?.showSubmitMusicLoading()
        }
    }
    
    private func submitMusic() async throws {
        do {
            viewModel.stopMusic()
            progressBar.cancelCompletion()
            try await viewModel.submitMusic()
            submitButton.updateButton(.submitted)
        } catch {
            throw error
        }
    }
}

// MARK: - Alert

extension SelectMusicViewController {
    private func showSubmitMusicLoading() {
        let alert = ASAlertController(
            progressText: .submitMusic,
            load: { [weak self] in
                try await self?.submitMusic()
            },
            errorCompletion: { [weak self] error in
                self?.showFailSubmitMusic(error)
            })
        presentLoadingView(alert)
    }
    
    private func showFailSubmitMusic(_ error: Error) {
        let alert = ASAlertController(titleText: .error(error))
        presentAlert(alert)
    }
}
