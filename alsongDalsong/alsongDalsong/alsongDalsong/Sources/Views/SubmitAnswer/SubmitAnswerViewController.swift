import Combine
import SwiftUI

final class SubmitAnswerViewController: UIViewController {
    private var progressBar = ProgressBar()
    private var musicPanel = MusicPanel()
    private var selectedMusicPanel = MusicPanel(.compact)
    private var selectAnswerButton = ASButton()
    private var submitButton = ASButton()
    private var submissionStatus = SubmissionStatusView()
    private var selectedAnswerView: UIHostingController<SelectAnswerView>?
    private var buttonStack = UIStackView()
    private let viewModel: SubmitAnswerViewModel
    private var cancellables: Set<AnyCancellable> = []

    init(viewModel: SubmitAnswerViewModel) {
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

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.cancelSubscriptions()
    }

    private func bindToComponents() {
        submissionStatus.bind(to: viewModel.$submissionStatus)
        progressBar.bind(to: viewModel.$dueTime)
        musicPanel.bind(to: viewModel.$music)
        selectedMusicPanel.bind(to: viewModel.$selectedMusic)
        submitButton.bind(to: viewModel.$musicData)

    }

    private func setupUI() {
        selectAnswerButton.setConfiguration(text: "정답 선택", backgroundColor: .asLightSky)
        submitButton.setConfiguration(text: "정답 제출", backgroundColor: .asLightGray)
        submitButton.updateButton(.disabled)
        buttonStack.axis = .horizontal
        buttonStack.spacing = 16
        buttonStack.addArrangedSubview(selectAnswerButton)
        buttonStack.addArrangedSubview(submitButton)
        view.backgroundColor = .asLightGray
    }

    private func setupLayout() {
        view.addSubview(progressBar)
        view.addSubview(musicPanel)
        view.addSubview(selectedMusicPanel)
        view.addSubview(buttonStack)
        view.addSubview(submissionStatus)

        progressBar.translatesAutoresizingMaskIntoConstraints = false
        musicPanel.translatesAutoresizingMaskIntoConstraints = false
        selectedMusicPanel.translatesAutoresizingMaskIntoConstraints = false
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

            selectedMusicPanel.topAnchor.constraint(equalTo: musicPanel.bottomAnchor, constant: 32),
            selectedMusicPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            selectedMusicPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            selectedMusicPanel.heightAnchor.constraint(equalToConstant: 100),

            submissionStatus.topAnchor.constraint(equalTo: buttonStack.topAnchor, constant: -16),
            submissionStatus.trailingAnchor.constraint(equalTo: buttonStack.trailingAnchor, constant: 16),

            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonStack.heightAnchor.constraint(equalToConstant: 64),
        ])
    }

    private func submitAnswer() async throws {
        do {
            viewModel.stopMusic()
            progressBar.cancelCompletion()
            try await viewModel.submitAnswer()
            submitButton.updateButton(.submitted)
            selectAnswerButton.updateButton(.disabled)
        } catch {
            throw error
        }
    }

    private func setAction() {
        selectAnswerButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            selectedAnswerView = UIHostingController(rootView: SelectAnswerView(viewModel: viewModel))
            if let sheet = selectedAnswerView?.sheetPresentationController {
                sheet.detents = [
                    .medium(),
                    .large(),
                ]
                sheet.prefersGrabberVisible = true
            }
            viewModel.stopMusic()
            guard let selectAnswerView = selectedAnswerView else { return }
            present(selectAnswerView, animated: true)
        },
        for: .touchUpInside)

        submitButton.addAction(
            UIAction { [weak self] _ in
                self?.showSubmitAnswerLoading()
            }, for: .touchUpInside
        )

        progressBar.setCompletionHandler { [weak self] in
            self?.showSubmitAnswerLoading()
        }
    }
}

// MARK: - Alert

extension SubmitAnswerViewController {
    private func showSubmitAnswerLoading() {
        let alert = LoadingAlertController(
            progressText: .submitMusic,
            loadAction: { [weak self] in
                try await self?.submitAnswer()
            }
        ) { [weak self] error in
            self?.showFailSubmitMusic(error)
        }
        presentAlert(alert)
    }

    private func showFailSubmitMusic(_ error: Error) {
        let alert = SingleButtonAlertController(titleText: .error(error))
        presentAlert(alert)
    }
}
