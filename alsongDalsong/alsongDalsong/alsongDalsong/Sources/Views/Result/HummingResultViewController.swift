import ASEntity
import Combine
import SwiftUI

class HummingResultViewController: UIViewController {
    private let musicList = ResultList()
    private let resultTableView = UITableView()
    private let nextButton = ASButton()

    private var resultTableViewDiffableDataSource: HummingResultTableViewDiffableDataSource?
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
        guard let viewModel else { return }
        resultTableViewDiffableDataSource = HummingResultTableViewDiffableDataSource(tableView: resultTableView, viewModel: viewModel)
        resultTableViewDiffableDataSource?.applySnapshot(newRecords: viewModel.currentRecords, submit: viewModel.currentsubmit)
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
                guard let self else { return }
                resultTableViewDiffableDataSource?.applySnapshot(newRecords: records, submit: viewModel.currentsubmit)
            }
            .store(in: &cancellables)

        viewModel.$currentsubmit
            .receive(on: DispatchQueue.main)
            .sink { [weak self] submit in
                guard let self else { return }
                if submit != nil {
                    nextButton.isHidden = false
                }
                resultTableViewDiffableDataSource?.applySnapshot(newRecords: viewModel.currentRecords, submit: submit)
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
