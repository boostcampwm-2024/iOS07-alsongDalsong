import SwiftUI

final class SelectMusicViewController: UIViewController {
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
    
    override func viewDidDisappear(_ animated: Bool) {
        viewModel.cancelSubscriptions()
    }
    
    private func bindToComponents() {
        progressBar.bind(to: viewModel.$dueTime)
        submitButton.bind(to: viewModel.$musicData)
        submissionStatus.bind(to: viewModel.$submissionStatus)
    }
    
    private func setupUI() {
        view.backgroundColor = .asLightGray
        submitButton.setConfiguration(text: "선택 완료", backgroundColor: .asGreen)
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
    
        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 16),
            
            selectMusicView.view.topAnchor.constraint(equalTo: progressBar.bottomAnchor),
            selectMusicView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            selectMusicView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            selectMusicView.view.bottomAnchor.constraint(equalTo: submitButton.topAnchor, constant: -20),
            
            submissionStatus.topAnchor.constraint(equalTo: submitButton.topAnchor, constant: -16),
            submissionStatus.trailingAnchor.constraint(equalTo: submitButton.trailingAnchor, constant: 16),

            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            submitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            submitButton.heightAnchor.constraint(equalToConstant: 64),
        ])
    }
    
    private func setAction() {
        submitButton.addAction(UIAction { [weak self] _ in
            self?.showSubmitMusicLoading()
        }, for: .touchUpInside)
        
        progressBar.setCompletionHandler { [weak self] in
            guard self?.viewModel.selectedMusic != nil else {
                self?.showSubmitRandomMusicLoading()
                return
            }
            self?.showSubmitMusicLoading()
        }
    }
    
    private func pickRandomMusic() async throws {
        do {
            try await viewModel.randomMusic()
        } catch {
            throw error
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
        let alert = LoadingAlertController(
            progressText: .submitMusic,
            loadAction: { [weak self] in
                try await self?.submitMusic()
            },
            errorCompletion: { [weak self] error in
                self?.showFailSubmitMusic(error)
            })
        presentAlert(alert)
    }
    
    private func showSubmitRandomMusicLoading() {
        let alert = LoadingAlertController(
            progressText: .submitMusic,
            loadAction: { [weak self] in
                try await self?.pickRandomMusic()
                try await self?.submitMusic()
            },
            errorCompletion: { [weak self] error in
                self?.showFailSubmitMusic(error)
            })
        presentAlert(alert)
    }
    
    private func showFailSubmitMusic(_ error: Error) {
        let alert = SingleButtonAlertController(titleText: .error(error))
        presentAlert(alert)
    }
}
