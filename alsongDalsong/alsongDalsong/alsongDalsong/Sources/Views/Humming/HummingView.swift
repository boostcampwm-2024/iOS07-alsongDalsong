import ASRepository
import UIKit

final class HummingViewController: UIViewController {
    // dueTime을 사용하는 timer 필요
    private var timer = UIView()
    private var guideLabel = GuideLabel()
    private var recordPanel = ASPanel()
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
    }

    private func bindToComponents() {
        submissionStatus.bind(to: vm.$submitStatus)
    }

    private func setupUI() {
        guideLabel.setText("허밍을 듣고 따라하세요!")
        view.backgroundColor = .asLightGray
        view.addSubview(timer)
        view.addSubview(guideLabel)
        view.addSubview(recordPanel)
        view.addSubview(recordButton)
        view.addSubview(submitButton)
        view.addSubview(submissionStatus)
    }

    /// 구현되지 않은 컴포넌트들의 placeholder
    private func setupPlaceholder() {
        timer.backgroundColor = .asYellow
        recordPanel.backgroundColor = .asMint
        submitButton.setConfiguration(title: "녹음 완료", backgroundColor: .asGreen)
    }

    private func setupLayout() {
        timer.translatesAutoresizingMaskIntoConstraints = false
        guideLabel.translatesAutoresizingMaskIntoConstraints = false
        recordPanel.translatesAutoresizingMaskIntoConstraints = false
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submissionStatus.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            timer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            timer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            timer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            timer.heightAnchor.constraint(equalToConstant: 15),

            guideLabel.topAnchor.constraint(equalTo: timer.bottomAnchor, constant: 53),
            guideLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            recordPanel.topAnchor.constraint(equalTo: guideLabel.bottomAnchor, constant: 68),
            recordPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            recordPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            recordPanel.heightAnchor.constraint(equalToConstant: 64),

            recordButton.topAnchor.constraint(equalTo: recordPanel.bottomAnchor, constant: 68),
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            submitButton.topAnchor.constraint(equalTo: recordButton.bottomAnchor, constant: 68),
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            submitButton.heightAnchor.constraint(equalToConstant: 64),

            submissionStatus.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 68),
            submissionStatus.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
}
