import ASContainer
import ASRepository
import UIKit

final class HummingViewController: UIViewController {
    private var progressBar = ProgressBar()
    private var guideLabel = GuideLabel()
    private var hummingPanel = AudioVisualizerView()
    private var recordButton = RecordButton()
    private var submitButton = ASButton()
    private var submissionStatus = SubmissionStatusView()
    private let vm: HummingViewModel

    init(vm: HummingViewModel) {
        self.vm = vm
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
        submissionStatus.bind(to: vm.$submissionStatus)
        progressBar.bind(to: vm.$dueTime)
        hummingPanel.bind(to: vm.$recorderAmplitude)
        submitButton.bind(to: vm.$humming)
    }

    private func setupUI() {
        guideLabel.setText("노래를 따라해 보세요!")
        hummingPanel.changeBackgroundColor(color: .asYellow)
        recordButton.addAction(UIAction {
            [weak self] _ in self?.vm.startRecording()
        },
        for: .touchUpInside)
        submitButton.setConfiguration(title: "녹음 완료", backgroundColor: .asLightGray)
        submitButton.addAction(
            UIAction { [weak self] _ in
                self?.vm.submitHumming()
                let gameStatusRepository = DIContainer.shared.resolve(GameStatusRepositoryProtocol.self)
                let playersRepository = DIContainer.shared.resolve(PlayersRepositoryProtocol.self)
                let submitsRepository = DIContainer.shared.resolve(SubmitsRepositoryProtocol.self)
                let recordsRepository = DIContainer.shared.resolve(RecordsRepositoryProtocol.self)
                let vm = RehummingViewModel(
                    gameStatusRepository: gameStatusRepository,
                    playersRepository: playersRepository,
                    recordsRepository: recordsRepository,
                    submitsRepository: submitsRepository
                )
                let vc = RehummingViewController(vm: vm)
                self?.navigationController?.pushViewController(vc, animated: true)
        }, for: .touchUpInside)
        submitButton.isEnabled = false
        view.backgroundColor = .asLightGray
        view.addSubview(progressBar)
        view.addSubview(guideLabel)
        view.addSubview(hummingPanel)
        view.addSubview(recordButton)
        view.addSubview(submitButton)
        view.addSubview(submissionStatus)
    }

    private func setupLayout() {
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        guideLabel.translatesAutoresizingMaskIntoConstraints = false
        hummingPanel.translatesAutoresizingMaskIntoConstraints = false
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

            hummingPanel.topAnchor.constraint(equalTo: guideLabel.bottomAnchor, constant: 68),
            hummingPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            hummingPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            hummingPanel.heightAnchor.constraint(equalToConstant: 64),

            recordButton.topAnchor.constraint(equalTo: hummingPanel.bottomAnchor, constant: 68),
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