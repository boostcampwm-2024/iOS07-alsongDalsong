import UIKit

final class HummingViewController: UIViewController {
    private var progressBar = ProgressBar()
    private var musicPanel = MusicPanel()
    private var hummingPanel = RecordingPanel(.asYellow)
    private var recordButton = ASButton()
    private var submitButton = ASButton()
    private var submissionStatus = SubmissionStatusView()
    private var buttonStack = UIStackView()
    private let viewModel: HummingViewModel

    init(viewModel: HummingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        setupUI()
        setupLayout()
        setAction()
        bindToComponents()
    }

    private func bindToComponents() {
        submissionStatus.bind(to: viewModel.$submissionStatus)
        progressBar.bind(to: viewModel.$dueTime)
        musicPanel.bind(to: viewModel.$music)
        hummingPanel.bind(to: viewModel.$isRecording)
        hummingPanel.onRecordingFinished = { [weak self] recordedData in
            self?.recordButton.updateButton(.reRecord)
            self?.viewModel.didRecordingFinished(recordedData)
        }
        submitButton.bind(to: viewModel.$recordedData)
    }

    private func setupUI() {
        recordButton.updateButton(.startRecord)
        submitButton.updateButton(.submit)
        submitButton.updateButton(.disabled)
        buttonStack.axis = .horizontal
        buttonStack.spacing = 16
        buttonStack.addArrangedSubview(recordButton)
        buttonStack.addArrangedSubview(submitButton)
        view.backgroundColor = .asLightGray
        view.addSubview(progressBar)
        view.addSubview(musicPanel)
        view.addSubview(hummingPanel)
        view.addSubview(buttonStack)
        view.addSubview(submissionStatus)
    }

    private func setAction() {
        recordButton.addAction(UIAction { [weak self] _ in
            self?.recordButton.updateButton(.recording)
            self?.viewModel.didTappedRecordButton()
        },
        for: .touchUpInside)

        submitButton.addAction(UIAction { [weak self] _ in
            self?.showSubmitHummingLoading()
        }, for: .touchUpInside)

        progressBar.setCompletionHandler { [weak self] in
            self?.showSubmitHummingLoading()
        }
    }

    private func setupLayout() {
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        musicPanel.translatesAutoresizingMaskIntoConstraints = false
        hummingPanel.translatesAutoresizingMaskIntoConstraints = false
        submissionStatus.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 16),

            musicPanel.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 32),
            musicPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            musicPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            hummingPanel.topAnchor.constraint(equalTo: musicPanel.bottomAnchor, constant: 32),
            hummingPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            hummingPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            hummingPanel.heightAnchor.constraint(equalToConstant: 84),

            submissionStatus.topAnchor.constraint(equalTo: buttonStack.topAnchor, constant: -16),
            submissionStatus.trailingAnchor.constraint(equalTo: buttonStack.trailingAnchor, constant: 16),

            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonStack.heightAnchor.constraint(equalToConstant: 64),
        ])
    }

    private func submitHumming() async throws {
        progressBar.cancelCompletion()
        viewModel.didTappedSubmitButton()
        submitButton.updateButton(.submitted)
        recordButton.updateButton(.disabled)
    }
}

// MARK: - Alert

extension HummingViewController {
    private func showSubmitHummingLoading() {
        let alert = LoadingAlertController(
            progressText: .submitHumming,
            loadAction: { [weak self] in
                try await self?.submitHumming()
            },
            errorCompletion: { [weak self] error in
                self?.showFailSubmitMusic(error)
            }
        )
        presentAlert(alert)
    }

    private func showFailSubmitMusic(_ error: Error) {
        let alert = SingleButtonAlertController(titleText: .error(error))
        presentAlert(alert)
    }
}
