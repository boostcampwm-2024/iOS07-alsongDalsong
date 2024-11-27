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
                Task {
                    guard let submitted = await self?.showSubmitLoading() else { return }
                    submitted ? self?.submitButton.updateButton(.submitted) : self?.submitButton.updateButton(.submit)
                }
                let gameStatusRepository = DIContainer.shared.resolve(GameStatusRepositoryProtocol.self)
                let playersRepository = DIContainer.shared.resolve(PlayersRepositoryProtocol.self)
                let recordsRepository = DIContainer.shared.resolve(RecordsRepositoryProtocol.self)
                let viewModel = RehummingViewModel(
                    gameStatusRepository: gameStatusRepository,
                    playersRepository: playersRepository,
                    recordsRepository: recordsRepository
                )
                let vc = RehummingViewController(viewModel: viewModel)
                self?.navigationController?.pushViewController(vc, animated: true)
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
            Task {
                await self?.showSubmitLoading()
            }
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

    func showSubmitLoading() async -> Bool {
        return await withCheckedContinuation { continuation in
            let alert = ASAlertController(progressText: .submitMusic) { [weak self] in
                guard let self else {
                    continuation.resume(returning: false)
                    return
                }
                Task {
                    let result = await self.viewModel.submitHumming()
                    continuation.resume(returning: result)
                }
            }
            presentLoadingView(alert)
        }
    }
}
