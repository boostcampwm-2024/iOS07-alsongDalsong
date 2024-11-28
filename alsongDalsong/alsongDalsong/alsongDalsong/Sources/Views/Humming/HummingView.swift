import ASContainer
import ASRepository
import UIKit

final class HummingViewController: UIViewController {
    private var progressBar = ProgressBar()
    private var guideLabel = GuideLabel()
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
        bindToComponents()
    }

    private func bindToComponents() {
        submissionStatus.bind(to: viewModel.$submissionStatus)
        progressBar.bind(to: viewModel.$dueTime)
        musicPanel.bind(to: viewModel.$music)
        hummingPanel.bind(to: viewModel.$isRecording)
        hummingPanel.onRecordingFinished = { [weak self] recordedData in
            self?.recordButton.updateButton(.reRecord)
            self?.viewModel.updateRecordedData(with: recordedData)
        }
        submitButton.bind(to: viewModel.$recordedData)
    }

    private func setupUI() {
        guideLabel.setText("노래를 따라해 보세요!")
        recordButton.updateButton(.startRecord)
        recordButton.addAction(UIAction { [weak self] _ in
            self?.recordButton.updateButton(.recording)
            self?.viewModel.startRecording()
        },
        for: .touchUpInside)
        submitButton.updateButton(.submit)
        submitButton.updateButton(.disabled)
        submitButton.addAction(
            UIAction { [weak self] _ in
                self?.showSubmitHummingLoading()
            }, for: .touchUpInside
        )
        buttonStack.axis = .horizontal
        buttonStack.spacing = 16
        buttonStack.addArrangedSubview(recordButton)
        buttonStack.addArrangedSubview(submitButton)
        view.backgroundColor = .asLightGray
        view.addSubview(progressBar)
        view.addSubview(guideLabel)
        view.addSubview(musicPanel)
        view.addSubview(hummingPanel)
        view.addSubview(buttonStack)
        view.addSubview(submissionStatus)

        progressBar.setCompletionHandler { [weak self] in
            self?.showSubmitHummingLoading()
        }
    }

    private func setupLayout() {
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        guideLabel.translatesAutoresizingMaskIntoConstraints = false
        musicPanel.translatesAutoresizingMaskIntoConstraints = false
        hummingPanel.translatesAutoresizingMaskIntoConstraints = false
        submissionStatus.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 16),

            guideLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 20),
            guideLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            musicPanel.topAnchor.constraint(equalTo: guideLabel.bottomAnchor, constant: 20),
            musicPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 48),
            musicPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -48),

            hummingPanel.topAnchor.constraint(equalTo: musicPanel.bottomAnchor, constant: 36),
            hummingPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            hummingPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            hummingPanel.heightAnchor.constraint(equalToConstant: 84),

            submissionStatus.topAnchor.constraint(equalTo: buttonStack.topAnchor, constant: -16),
            submissionStatus.trailingAnchor.constraint(equalTo: buttonStack.trailingAnchor, constant: 16),

            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            buttonStack.heightAnchor.constraint(equalToConstant: 64),
        ])
    }

    private func submitHumming() async throws {
        do {
            progressBar.cancelCompletion()
            try await viewModel.submitHumming()
            submitButton.updateButton(.complete)
        } catch {
            throw error
        }
    }
}

// MARK: - Alert

extension HummingViewController {
    private func showSubmitHummingLoading() {
        let alert = ASAlertController(
            progressText: .submitHumming,
            load:
                { [weak self] in
                    try await self?.submitHumming()
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
