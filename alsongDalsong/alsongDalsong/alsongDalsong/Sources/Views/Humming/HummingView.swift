import ASRepository
import UIKit

final class HummingViewController: UIViewController {
    private var progressBar = ProgressBar()
    private var guideLabel = GuideLabel()
    private var recordPanel = AudioVisualizerView()
    private var recordButton = RecordButton()
    private var submitButton = ASButton()
    private var submissionStatus = SubmissionStatusView()
    private let vm: HummingViewModel

    init(
        gameStatusRepository: GameStatusRepositoryProtocol,
        playersRepository: PlayersRepositoryProtocol,
        submitsRepository: SubmitsRepositoryProtocol
    ) {
        vm = HummingViewModel(
            gameStatusRepository: gameStatusRepository,
            playersRepository: playersRepository,
            submitsRepository: submitsRepository
        )
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        setupUI()
        setupLayout()
        setupPlaceholder()
        bindToComponents()
    }

    private func bindToComponents() {
        submissionStatus.bind(to: vm.$submissionStatus)
        progressBar.bind(to: vm.$dueTime)
    }

    private func setupUI() {
        guideLabel.setText("노래를 따라해 보세요!")
        view.backgroundColor = .asLightGray
        view.addSubview(progressBar)
        view.addSubview(guideLabel)
        view.addSubview(recordPanel)
        view.addSubview(recordButton)
        view.addSubview(submitButton)
        view.addSubview(submissionStatus)
    }

    private func setupPlaceholder() {
        submitButton.setConfiguration(title: "녹음 완료", backgroundColor: .asGreen)
    }

    private func setupLayout() {
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        guideLabel.translatesAutoresizingMaskIntoConstraints = false
        recordPanel.translatesAutoresizingMaskIntoConstraints = false
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submissionStatus.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 16),

            guideLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 56),
            guideLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            recordPanel.topAnchor.constraint(equalTo: guideLabel.bottomAnchor, constant: 68),
            recordPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            recordPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            recordPanel.heightAnchor.constraint(equalToConstant: 64),

            recordButton.topAnchor.constraint(equalTo: recordPanel.bottomAnchor, constant: 68),
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            submitButton.bottomAnchor.constraint(equalTo: submissionStatus.topAnchor, constant: -24),
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            submitButton.heightAnchor.constraint(equalToConstant: 64),

            submissionStatus.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            submissionStatus.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
}
