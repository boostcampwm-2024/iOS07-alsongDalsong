import ASContainer
import ASRepository
import Combine
import MusicKit
import SwiftUI
import UIKit

final class SubmitAnswerViewController: UIViewController {
    private var progressBar = ProgressBar()
    private var guideLabel = GuideLabel()
    private var musicPanel = MusicPanel()
    private var selectedSongView: UIHostingController<ASMusicItemCell>?
    private var selectAnswerButton = ASButton()
    private var submitButton = ASButton()
    private var submissionStatus = SubmissionStatusView()
    private var buttonStack = UIStackView()
    private let vm: SubmitAnswerViewModel
    private var cancellables: Set<AnyCancellable> = []

    init(vm: SubmitAnswerViewModel) {
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
        submitButton.bind(to: vm.$musicData)
    }

    private func setupUI() {
        guideLabel.setText("허밍을 듣고 정답을 맞춰보세요!")
        selectAnswerButton.setConfiguration(title: "정답 선택", backgroundColor: .asLightSky)
        selectAnswerButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            let selecAnswerView = UIHostingController(rootView: SelectAnswerView(viewModel: self.vm))
            present(selecAnswerView, animated: true)
        },
        for: .touchUpInside)
        submitButton.setConfiguration(title: "정답 제출", backgroundColor: .asLightGray)
        submitButton.addAction(
            UIAction { [weak self] _ in
                self?.vm.submitAnswer()
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

        submitButton.updateButton(.disabled)
        buttonStack.axis = .horizontal
        buttonStack.spacing = 16
        buttonStack.addArrangedSubview(selectAnswerButton)
        buttonStack.addArrangedSubview(submitButton)
        view.backgroundColor = .asLightGray
        view.addSubview(progressBar)
        view.addSubview(guideLabel)
        view.addSubview(musicPanel)
        view.addSubview(buttonStack)
        view.addSubview(submissionStatus)

        submitButton.isEnabled = false
    }

    private func setupLayout() {
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        guideLabel.translatesAutoresizingMaskIntoConstraints = false
        musicPanel.translatesAutoresizingMaskIntoConstraints = false
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

            submissionStatus.topAnchor.constraint(equalTo: buttonStack.topAnchor, constant: -16),
            submissionStatus.trailingAnchor.constraint(equalTo: buttonStack.trailingAnchor, constant: 16),

            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            buttonStack.heightAnchor.constraint(equalToConstant: 64),
        ])
    }
}
