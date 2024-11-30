import Combine
import SwiftUI

final class SubmitAnswerViewController: UIViewController {
    private var progressBar = ProgressBar()
    private var guideLabel = GuideLabel()
    private var musicPanel = MusicPanel()
    private var selectedSongView: UIHostingController<ASMusicItemCell>?
    private var selectAnswerButton = ASButton()
    private var submitButton = ASButton()
    private var submissionStatus = SubmissionStatusView()
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
        viewModel.cancelSubscriptions()
    }

    private func bindToComponents() {
        submissionStatus.bind(to: viewModel.$submissionStatus)
        progressBar.bind(to: viewModel.$dueTime)
        musicPanel.bind(to: viewModel.$music)
        submitButton.bind(to: viewModel.$musicData)
    }

    private func setupUI() {
        guideLabel.setText("허밍을 듣고 정답을 맞춰보세요!")
        selectAnswerButton.setConfiguration(title: "정답 선택", backgroundColor: .asLightSky)
        submitButton.setConfiguration(title: "정답 제출", backgroundColor: .asLightGray)
        submitButton.updateButton(.disabled)
        buttonStack.axis = .horizontal
        buttonStack.spacing = 16
        buttonStack.addArrangedSubview(selectAnswerButton)
        buttonStack.addArrangedSubview(submitButton)
        view.backgroundColor = .asLightGray
    }

    private func setupLayout() {
        view.addSubview(progressBar)
        view.addSubview(guideLabel)
        view.addSubview(musicPanel)
        view.addSubview(buttonStack)
        view.addSubview(submissionStatus)

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
            let selecAnswerView = UIHostingController(rootView: SelectAnswerView(viewModel: viewModel))
            present(selecAnswerView, animated: true)
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
        let alert = ASAlertController(progressText: .submitMusic, load: { [weak self] in
            try await self?.submitAnswer()
        }) { [weak self] error in
            self?.showFailSubmitMusic(error)
        }
        presentLoadingView(alert)
    }

    private func showFailSubmitMusic(_ error: Error) {
        let alert = ASAlertController(titleText: .error(error))
        presentAlert(alert)
    }
}
