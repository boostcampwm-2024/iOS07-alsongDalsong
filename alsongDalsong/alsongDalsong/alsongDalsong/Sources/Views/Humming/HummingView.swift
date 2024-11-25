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
        musicPanel.bind(to: vm.$music)
        hummingPanel.bind(to: vm.$isRecording)
        hummingPanel.onRecordingFinished = { [weak self] recordedData in
            self?.vm.updateRecordedData(with: recordedData)
        }
        submitButton.bind(to: vm.$recordedData)
    }

    private func setupUI() {
        guideLabel.setText("노래를 따라해 보세요!")
        recordButton.setConfiguration(title: "녹음하기", backgroundColor: .asLightRed)
        recordButton.addAction(UIAction { [weak self] _ in
            self?.vm.startRecording()
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
            }, for: .touchUpInside
        )
        submitButton.isEnabled = false
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
}
