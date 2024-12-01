import Combine
import SwiftUI

final class LobbyViewController: UIViewController {
    let topNavigationView = UIView()
    let backButton = UIButton()
    let codeLabel = UILabel()
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
            .sink { [weak self] roomNumber in
                self?.codeLabel.text = "#\(roomNumber)"
            }
            .store(in: &cancellables)

        viewmodel.$isHost
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isHost in
                self?.startButton.isEnabled = isHost
            }
            .store(in: &cancellables)

        viewmodel.$canBeginGame
            .receive(on: DispatchQueue.main)
            .sink { [weak self] canBeginGame in
                if !canBeginGame {
                    self?.startButton.updateButton(.waitStart)
                    self?.startButton.updateButton(.disabled)
                } else {
                    self?.startButton.updateButton(.startGame)
                    self?.startButton.isEnabled = true
                }
            }
            .store(in: &cancellables)
    }

    private func setupUI() {
        view.backgroundColor = .asLightGray
        topNavigationView.translatesAutoresizingMaskIntoConstraints = false

        backButton.translatesAutoresizingMaskIntoConstraints = false
        var configuration = UIButton.Configuration.plain()

        configuration.image = UIImage(systemName: "rectangle.portrait.and.arrow.forward")?
            .withRenderingMode(.alwaysTemplate)
            .withTintColor(.label)
            .applyingSymbolConfiguration(.init(pointSize: 24, weight: .medium))?
            .rotate(radians: .pi)
        backButton.configuration = configuration
        backButton.tintColor = .asBlack

        codeLabel.translatesAutoresizingMaskIntoConstraints = false
        codeLabel.font = .font(forTextStyle: .title1)
        codeLabel.textColor = .label
        codeLabel.textAlignment = .center

        inviteButton.setConfiguration(systemImageName: "link", title: "초대하기!", backgroundColor: .asYellow)
        inviteButton.translatesAutoresizingMaskIntoConstraints = false

        startButton.setConfiguration(systemImageName: "play.fill", title: "시작하기!", backgroundColor: .asMint)
        startButton.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setAction() {
        backButton.addAction(
            UIAction { [weak self] _ in
                let alert = DefaultAlertController(
                    titleText: .leaveRoom,
                    primaryButtonText: .leave,
                    secondaryButtonText: .cancel
                ) { [weak self] _ in
                    self?.viewmodel.leaveRoom()
                    self?.navigationController?.popViewController(animated: true)
                }
                self?.presentAlert(alert)
            },
            for: .touchUpInside
        )

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
        view.addSubview(topNavigationView)
        topNavigationView.addSubview(codeLabel)
        topNavigationView.addSubview(backButton)

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            topNavigationView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            topNavigationView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            topNavigationView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            topNavigationView.heightAnchor.constraint(equalToConstant: 44),

            backButton.leadingAnchor.constraint(equalTo: topNavigationView.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: topNavigationView.centerYAnchor),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            backButton.widthAnchor.constraint(equalToConstant: 44),

            codeLabel.centerYAnchor.constraint(equalTo: topNavigationView.centerYAnchor),
            codeLabel.centerXAnchor.constraint(equalTo: topNavigationView.centerXAnchor),

            lobbyView.view.topAnchor.constraint(equalTo: topNavigationView.bottomAnchor),
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
