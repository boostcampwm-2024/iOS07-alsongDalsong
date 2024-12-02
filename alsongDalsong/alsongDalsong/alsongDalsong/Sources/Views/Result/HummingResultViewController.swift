import ASEntity
import Combine
import SwiftUI

class HummingResultViewController: UIViewController {
    private let musicList = ResultList()
    private let resultTableView = UITableView()
    private let nextButton = ASButton()

    private var viewModel: HummingResultViewModel?
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: HummingResultViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        viewModel = nil
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .asLightGray
        setResultTableView()
        setButton()
        setConstraints()
        bind()
    }

    override func viewDidDisappear(_: Bool) {
        viewModel?.cancelSubscriptions()
    }

    private func setResultTableView() {
        resultTableView.dataSource = self
        resultTableView.separatorStyle = .none
        resultTableView.allowsSelection = false
        resultTableView.backgroundColor = .asLightGray
        resultTableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        view.addSubview(resultTableView)
    }

    private func setButton() {
        nextButton.setConfiguration(
            systemImageName: "play.fill",
            text: "다음으로",
            backgroundColor: .asMint
        )
        view.addSubview(nextButton)
        nextButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            showNextResultLoading()
        }, for: .touchUpInside)
        nextButton.isHidden = true
    }

    private func setConstraints() {
        view.addSubview(musicList)

        musicList.translatesAutoresizingMaskIntoConstraints = false
        resultTableView.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false

        let layoutGuide = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            musicList.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 20),
            musicList.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 16),
            musicList.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -16),
            musicList.heightAnchor.constraint(equalToConstant: 130),

            resultTableView.topAnchor.constraint(equalTo: musicList.bottomAnchor, constant: 20),
            resultTableView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            resultTableView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),
            resultTableView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -30),

            nextButton.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 24),
            nextButton.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -24),
            nextButton.heightAnchor.constraint(equalToConstant: 64),
            nextButton.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: -24),
        ])
    }

    private func bind() {
        guard let viewModel else { return }
        musicList.bind(to: viewModel.$currentResult) { [weak self] url in
            await self?.viewModel?.getArtworkData(url: url)
        } musicFetcher: {
            await self.viewModel?.startPlaying()
        }

        viewModel.$currentRecords
            .receive(on: DispatchQueue.main)
            .sink { [weak self] records in
                guard let self, !records.isEmpty else { return }
                let indexPath = IndexPath(row: records.count - 1, section: 0)
                if records.count > resultTableView.numberOfRows(inSection: 0) {
                    resultTableView.insertRows(at: [indexPath], with: .fade)
                }
                else {
                    resultTableView.reloadRows(at: [indexPath], with: .fade)
                }
            }
            .store(in: &cancellables)

        viewModel.$currentsubmit
            .receive(on: DispatchQueue.main)
            .sink { [weak self] submit in
                guard let self else { return }
                if submit != nil {
                    nextButton.isHidden = false
                    let indexPath = IndexPath(row: 0, section: 1)
                    if resultTableView.numberOfRows(inSection: 1) == 1 {
                        resultTableView.reloadRows(at: [indexPath], with: .fade)
                    }
                    else {
                        resultTableView.insertRows(at: [indexPath], with: .fade)
                    }
                }
            }
            .store(in: &cancellables)

        viewModel.$isNext
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isNext in
                guard let self else { return }
                if isNext {
                    viewModel.nextResultFetch()
                    nextButton.isHidden = true
                    if viewModel.hummingResult.isEmpty {
                        nextButton.updateButton(.complete)
                        nextButton.removeTarget(nil, action: nil, for: .touchUpInside)
                        nextButton.addAction(UIAction { _ in
                            self.showLobbyLoading()
                        }, for: .touchUpInside)
                    }
                    viewModel.isNext = false
                    resultTableView.reloadData()
                }
            }
            .store(in: &cancellables)

        viewModel.$isHost
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isHost in
                guard let self else { return }
                self.nextButton.isEnabled = isHost
            }
            .store(in: &cancellables)
    }

    private func nextResultFetch() async throws {
        guard let viewModel else { return }
        do {
            if viewModel.hummingResult.isEmpty {
                try await viewModel.navigationToLobby()
            }
            else {
                try await viewModel.changeRecordOrder()
            }
        }
        catch {
            throw error
        }
    }
}

extension HummingResultViewController: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        2
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel else { return 0 }
        if section == 0 {
            return viewModel.currentRecords.count
        }
        if viewModel.currentsubmit != nil {
            return 1
        }
        else { return 0 }
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = .clear
        guard let viewModel else { return cell }

        if indexPath.section == 0 {
            cell.contentConfiguration = UIHostingConfiguration {
                let currentPlayer = viewModel.currentRecords[indexPath.row].player
                HStack {
                    Spacer()
                    if indexPath.row % 2 == 0 {
                        if let avatarURL = currentPlayer?.avatarUrl {
                            SpeechBubbleCell(
                                alignment: .left,
                                messageType: .record,
                                avatarImagePublisher: { url in
                                    await viewModel.getAvatarData(url: url)
                                },
                                avatarURL: avatarURL,
                                artworkImagePublisher: { url in
                                    await viewModel.getArtworkData(url: url)
                                },
                                artworkURL: nil,
                                name: currentPlayer?.nickname ?? ""
                            )
                        }
                    }
                    else {
                        if let avatarURL = currentPlayer?.avatarUrl {
                            SpeechBubbleCell(
                                alignment: .right,
                                messageType: .record,
                                avatarImagePublisher: { url in
                                    await viewModel.getAvatarData(url: url)
                                },
                                avatarURL: avatarURL,
                                artworkImagePublisher: { url in
                                    await viewModel.getArtworkData(url: url)
                                },
                                artworkURL: nil,
                                name: currentPlayer?.nickname ?? ""
                            )
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
        }
        else {
            cell.contentConfiguration = UIHostingConfiguration {
                HStack {
                    Spacer()
                    if viewModel.currentRecords.count % 2 == 0 {
                        if let submit = viewModel.currentsubmit,
                           let avatarURL = submit.player?.avatarUrl,
                           let artworkURL = submit.music?.artworkUrl
                        {
                            SpeechBubbleCell(
                                alignment: .left,
                                messageType: .music(submit.music ?? .musicStub1),
                                avatarImagePublisher: { url in
                                    await viewModel.getAvatarData(url: url)
                                },
                                avatarURL: avatarURL,
                                artworkImagePublisher: { url in
                                    await viewModel.getArtworkData(url: url)
                                },
                                artworkURL: artworkURL,
                                name: submit.player?.nickname ?? ""
                            )
                        }
                    }
                    else {
                        if let submit = viewModel.currentsubmit,
                           let avatarURL = submit.player?.avatarUrl,
                           let artworkURL = submit.music?.artworkUrl
                        {
                            SpeechBubbleCell(
                                alignment: .right,
                                messageType: .music(submit.music ?? .musicStub1),
                                avatarImagePublisher: { url in
                                    await viewModel.getAvatarData(url: url)
                                },
                                avatarURL: avatarURL,
                                artworkImagePublisher: { url in
                                    await viewModel.getArtworkData(url: url)
                                },
                                artworkURL: artworkURL,
                                name: submit.player?.nickname ?? ""
                            )
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
        }

        return cell
    }
}

extension HummingResultViewController {
    private func showNextResultLoading() {
        let alert = LoadingAlertController(
            progressText: .nextResult,
            loadAction: { [weak self] in
                try await self?.nextResultFetch()
            },
            errorCompletion: { [weak self] error in
                self?.showFailNextLoading(error)
            }
        )
        presentAlert(alert)
    }

    private func showLobbyLoading() {
        let alert = LoadingAlertController(
            progressText: .toLobby,
            loadAction: { [weak self] in
                try await self?.nextResultFetch()
            },
            errorCompletion: { [weak self] error in
                self?.showFailNextLoading(error)
            }
        )
        presentAlert(alert)
    }

    private func showFailNextLoading(_ error: Error) {
        let alert = SingleButtonAlertController(titleText: .error(error))
        presentAlert(alert)
    }
}
