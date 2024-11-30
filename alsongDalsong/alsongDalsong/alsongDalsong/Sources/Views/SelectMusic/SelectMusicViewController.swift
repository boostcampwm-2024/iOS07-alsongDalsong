import SwiftUI

class SelectMusicViewController: UIViewController {
    private var progressBar = ProgressBar()
    private var selectMusicView = UIViewController()
    private let submitButton = ASButton()
    private var submissionStatus = SubmissionStatusView()
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
        submissionStatus.bind(to: viewModel.$submissionStatus)
    }
    
    private func setupUI() {
        view.backgroundColor = .asLightGray
        submitButton.setConfiguration(title: "선택 완료", backgroundColor: .asGreen)
        submitButton.updateButton(.disabled)
        let musicView = SelectMusicView(viewModel: viewModel)
        selectMusicView = UIHostingController(rootView: musicView)
        
        view.addSubview(selectMusicView.view)
        view.addSubview(progressBar)
        view.addSubview(submitButton)
        view.addSubview(submissionStatus)
    }
    
    private func setupLayout() {
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        submissionStatus.translatesAutoresizingMaskIntoConstraints = false
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        selectMusicView.view.translatesAutoresizingMaskIntoConstraints = false
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
            
            submissionStatus.topAnchor.constraint(equalTo: submitButton.topAnchor, constant: -16),
            submissionStatus.trailingAnchor.constraint(equalTo: submitButton.trailingAnchor, constant: 16),

            submitButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 24),
            submitButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -24),
            submitButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -24),
            submitButton.heightAnchor.constraint(equalToConstant: 64),
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
