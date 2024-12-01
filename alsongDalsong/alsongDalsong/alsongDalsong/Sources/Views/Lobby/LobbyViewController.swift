import Combine
import SwiftUI

final class LobbyViewController: UIViewController {
    let inviteButton = ASButton()
    let startButton = ASButton()
    private var hostingController: UIHostingController<LobbyView>?

    let viewmodel: LobbyViewModel
    private var cancellables: Set<AnyCancellable> = []

    init(lobbyViewModel: LobbyViewModel) {
        viewmodel = lobbyViewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        setAction()
        bindToComponents()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if viewmodel.isLeaveRoom {
            hostingController?.view.removeFromSuperview()
            hostingController = nil
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if viewmodel.isLeaveRoom {
            viewmodel.leaveRoom()
        }
    }

    private func bindToComponents() {
        viewmodel.$roomNumber
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
            }
            .store(in: &cancellables)

        viewmodel.$canBeginGame.combineLatest(viewmodel.$isHost)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] canBeginGame, isHost in
                if isHost {
                    if canBeginGame {
                        self?.startButton.updateButton(.startGame)
                        self?.startButton.isEnabled = true
                    }
                    else {
                        self?.startButton.updateButton(.needMorePlayers)
                        self?.startButton.updateButton(.disabled)
                    }
                }
                else {
                    self?.startButton.updateButton(.hostSelecting)
                    self?.startButton.updateButton(.disabled)
                }
            }
            .store(in: &cancellables)
    }

    private func setupUI() {
        view.backgroundColor = .asLightGray

        inviteButton.setConfiguration(
            systemImageName: "link",
            text: "초대하기!",
            backgroundColor: .asYellow
        )
        inviteButton.translatesAutoresizingMaskIntoConstraints = false

        startButton.setConfiguration(
            systemImageName: "play.fill",
            text: "시작하기!",
            backgroundColor: .asMint
        )
        startButton.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setAction() {
        inviteButton.addAction(UIAction { [weak self] _ in
            guard let roomNumber = self?.viewmodel.roomNumber else { return }
            if let url = URL(string: "alsongDalsong://invite/?roomnumber=\(roomNumber)") {
                let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self?.inviteButton
                self?.present(activityViewController, animated: true, completion: nil)
            }
        }, for: .touchUpInside)

        startButton.addAction(
            UIAction { [weak self] _ in
                guard let playerCount = self?.viewmodel.players.count else { return }
                if playerCount < 3 {
                    let alert = DefaultAlertController(
                        titleText: .needMorePlayer,
                        primaryButtonText: .keep,
                        secondaryButtonText: .cancel
                    ) { [weak self] _ in
                        self?.showStartGameLoading()
                    }
                    self?.presentAlert(alert)
                } else {
                    self?.showStartGameLoading()
                }
            },
            for: .touchUpInside
        )
    }

    private func setupLayout() {
        let lobbyView = UIHostingController(rootView: LobbyView(viewModel: viewmodel))
        hostingController = lobbyView
        lobbyView.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lobbyView.view)
        view.addSubview(startButton)
        view.addSubview(inviteButton)

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            lobbyView.view.topAnchor.constraint(equalTo: safeArea.topAnchor),
            lobbyView.view.bottomAnchor.constraint(equalTo: inviteButton.topAnchor, constant: -20),
            lobbyView.view.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            lobbyView.view.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),

            inviteButton.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -25),
            inviteButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 24),
            inviteButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -24),
            inviteButton.heightAnchor.constraint(equalToConstant: 64),

            startButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -25),
            startButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 24),
            startButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -24),
            startButton.heightAnchor.constraint(equalToConstant: 64),
        ])
    }

    private func gameStart() async throws {
        do {
            try await viewmodel.gameStart()
        } catch {
            throw error
        }
    }
}

// MARK: - Alert

extension LobbyViewController {
    func showStartGameLoading() {
        let alert = LoadingAlertController(
            progressText: .startGame,
            loadAction: { [weak self] in
                try await self?.gameStart()
            },
            errorCompletion: { [weak self] error in
                self?.showStartGameFailed(error)
            }
        )
        presentAlert(alert)
    }

    func showStartGameFailed(_ error: Error) {
        let alert = SingleButtonAlertController(titleText: .error(error))
        presentAlert(alert)
    }
}
