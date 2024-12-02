import ASEntity
import Combine
import SwiftUI

class HummingResultViewController: UIViewController {
    private let musicResultView = MusicResultView(frame: .zero)
    private let resultTableView = UITableView()
    private let button = ASButton()
    
    private var viewModel: HummingResultViewModel?
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: HummingResultViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = nil
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .asLightGray
        setResultTableView()
        setButton()
        setConstraints()
        bind()
        viewModel?.fetchResult()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        viewModel?.cancelSubscriptions()
        cancellables.removeAll()
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
        button.setConfiguration(
            systemImageName: "play.fill",
            text: "다음으로",
            backgroundColor: .asMint
        )
        view.addSubview(button)
        button.addAction(UIAction { [weak self] _ in
            guard let self, let viewModel else { return }
            showNextResultLoading()
        }, for: .touchUpInside)
        button.isHidden = true
    }
    
    private func setConstraints() {
        view.addSubview(musicResultView)
        
        musicResultView.translatesAutoresizingMaskIntoConstraints = false
        resultTableView.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let layoutGuide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            musicResultView.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 20),
            musicResultView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 16),
            musicResultView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -16),
            musicResultView.heightAnchor.constraint(equalToConstant: 130),
            
            resultTableView.topAnchor.constraint(equalTo: musicResultView.bottomAnchor, constant: 20),
            resultTableView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            resultTableView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),
            resultTableView.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -30),
            
            button.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 24),
            button.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -24),
            button.heightAnchor.constraint(equalToConstant: 64),
            button.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: -25)
        ])
    }
    
    private func bind() {
        guard let viewModel else { return }
        musicResultView.bind(to: viewModel.$currentResult) { [weak self] url in
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
                    button.isHidden = false
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
                    button.isHidden = true
                    if viewModel.hummingResult.isEmpty {
                        button.updateButton(.complete)
                        button.removeTarget(nil, action: nil, for: .touchUpInside)
                        button.addAction(UIAction { _ in
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
                if isHost {
                    self.button.isEnabled = true
                }
                else {
                    self.button.isEnabled = false
                }
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
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel else { return 0 }
        if section == 0 {
            return viewModel.currentRecords.count
        }
        if viewModel.currentsubmit != nil {
            return 1
        }
        else { return 0 }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
                                messageType: .record(viewModel.currentRecords[indexPath.row]),
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
                                messageType: .record(viewModel.currentRecords[indexPath.row]),
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
            }
        }
        else {
            cell.contentConfiguration = UIHostingConfiguration {
                HStack {
                    Spacer()
                    if viewModel.currentRecords.count % 2 == 0 {
                        if let submit = viewModel.currentsubmit, let avatarURL = submit.player?.avatarUrl, let artworkURL = submit.music?.artworkUrl {
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
                        if let submit = viewModel.currentsubmit, let avatarURL = submit.player?.avatarUrl, let artworkURL = submit.music?.artworkUrl {
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

final class MusicResultView: UIView {
    private let albumImageView = UIImageView()
    private let musicNameLabel = UILabel()
    private let singerNameLabel = UILabel()
    private let titleLabel = UILabel()
    private var cancellables = Set<AnyCancellable>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupConstraints()
    }
    
    func bind(
        to dataSource: Published<Answer?>.Publisher,
        fetcher: @escaping (URL?) async -> Data?,
        musicFetcher: @escaping () async -> Void?
    ) {
        dataSource
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] answer in
                self?.musicNameLabel.text = answer.music?.title
                self?.singerNameLabel.text = answer.music?.artist
                Task {
                    guard let url = answer.music?.artworkUrl else { return }
                    let data = await fetcher(url)
                    self?.setImage(data: data)
                    await musicFetcher()
                }
            }
            .store(in: &cancellables)
    }
    
    private func setImage(data: Data?) {
        guard let data else { return }
        albumImageView.image = UIImage(data: data)
    }

    private func setupView() {
        backgroundColor = .asSystem
        
        titleLabel.text = "정답은..."
        titleLabel.font = .font(ofSize: 24)
        titleLabel.textColor = .asBlack
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        albumImageView.contentMode = .scaleAspectFill
        albumImageView.layer.cornerRadius = 6
        albumImageView.clipsToBounds = true
        albumImageView.translatesAutoresizingMaskIntoConstraints = false
        albumImageView.image = UIImage(named: "mojojojo") // Placeholder image
        addSubview(albumImageView)

        musicNameLabel.font = .font(ofSize: 24)
        musicNameLabel.textColor = .asBlack
        musicNameLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(musicNameLabel)

        singerNameLabel.font = .font(ofSize: 24)
        singerNameLabel.textColor = UIColor.gray
        singerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(singerNameLabel)
        
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.asShadow.cgColor
        layer.shadowOffset = CGSize(width: 4, height: 4)
        layer.shadowRadius = 0
        layer.shadowOpacity = 1.0
        layer.borderWidth = 3
        layer.borderColor = UIColor.black.cgColor
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            albumImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            albumImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            albumImageView.widthAnchor.constraint(equalToConstant: 60),
            albumImageView.heightAnchor.constraint(equalToConstant: 60),

            musicNameLabel.topAnchor.constraint(equalTo: albumImageView.topAnchor),
            musicNameLabel.leadingAnchor.constraint(equalTo: albumImageView.trailingAnchor, constant: 15),
            musicNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            singerNameLabel.topAnchor.constraint(equalTo: musicNameLabel.bottomAnchor, constant: 4),
            singerNameLabel.leadingAnchor.constraint(equalTo: albumImageView.trailingAnchor, constant: 15),
            singerNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
}
