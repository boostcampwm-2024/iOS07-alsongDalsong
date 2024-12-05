import ASEntity
import ASLogKit
import Combine
import SwiftUI

class HummingResultViewController: UIViewController {
    private let answerView = MusicPanelView()
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
        setupUI()
        setupLayout()
        bindViewModel()
        viewModel?.bindResult()
    }

    override func viewDidDisappear(_: Bool) {
        viewModel?.cancelSubscriptions()
    }

    private func setupUI() {
        setResultTableView()
        setButton()
        setAction()
        view.addSubview(resultTableView)
        view.addSubview(nextButton)
        view.addSubview(answerView)
    }

    private func setResultTableView() {
        resultTableViewDiffableDataSource = HummingResultTableViewDiffableDataSource(tableView: resultTableView)
        resultTableView.separatorStyle = .none
        resultTableView.allowsSelection = false
        resultTableView.backgroundColor = .asLightGray
        resultTableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    }

    private func setButton() {
        nextButton.setConfiguration(
            systemImageName: "play.fill",
            text: "다음으로",
            backgroundColor: .asMint
        )
        nextButton.updateButton(.disabled)
    }

    private func setAction() {
        nextButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            showNextResultLoading()
        }, for: .touchUpInside)
    }

    private func setupLayout() {
        answerView.translatesAutoresizingMaskIntoConstraints = false
        resultTableView.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            answerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            answerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            answerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            answerView.heightAnchor.constraint(equalToConstant: 130),

            resultTableView.topAnchor.constraint(equalTo: answerView.bottomAnchor, constant: 20),
            resultTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultTableView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -30),

            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            nextButton.heightAnchor.constraint(equalToConstant: 64),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    func addDataSource(_ phase: ResultPhase, result: Result) {
        if case let .record(count) = phase {
            var updateResult = result
            let records = updateResult.records[0 ... count]
            updateResult.records = Array(records)
            updateResult.submit = nil
            Logger.debug("record update", updateResult)
            resultTableViewDiffableDataSource?.applySnapshot(updateResult)
            return
        }
        if case .submit = phase {
            Logger.debug("submit update", result)
            resultTableViewDiffableDataSource?.applySnapshot(result)
            return
        }
        if case .answer = phase {
            resultTableViewDiffableDataSource?.applySnapshot((result.answer, [], nil))
        }
    }

    private func changeButton(_ phase: ResultPhase) {
        if case .none = phase {
            nextButton.setConfiguration(
                systemImageName: "play.fill",
                text: "다음으로",
                backgroundColor: .asMint
            )
            nextButton.isEnabled = true
            nextButton.removeTarget(nil, action: nil, for: .touchUpInside)
            nextButton.addAction(UIAction { _ in
                self.showNextResultLoading()
            }, for: .touchUpInside)
        } else {
            nextButton.updateButton(.disabled)
        }
    }

    private func bindViewModel() {
        guard let viewModel else { return }
        answerView.bind(to: viewModel.$result)

        viewModel.$resultPhase
            .combineLatest(viewModel.$result, viewModel.$isHost)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] phase, result, isHost in
                guard let self else { return }
                addDataSource(phase, result: result)
                if result.answer != nil, isHost {
                    changeButton(phase)
                }
            }
            .store(in: &cancellables)

        viewModel.$canEndGame
            .receive(on: DispatchQueue.main)
            .sink { [weak self] canEndGame in
                guard let self else { return }
                if canEndGame {
                    nextButton.updateButton(.complete)
                    nextButton.isEnabled = true
                    nextButton.removeTarget(nil, action: nil, for: .touchUpInside)
                    nextButton.addAction(UIAction { _ in
                        self.showLobbyLoading()
                    }, for: .touchUpInside)
                } else {
                    nextButton.updateButton(.disabled)
                }
            }
            .store(in: &cancellables)
    }
}

extension HummingResultViewController {
    private func showNextResultLoading() {
        let alert = LoadingAlertController(
            progressText: .nextResult,
            loadAction: { [weak self] in
                await self?.viewModel?.changeRecordOrder()
            },
            errorCompletion: { [weak self] error in
                self?.showFailedAlert(error)
            }
        )
        presentAlert(alert)
    }

    private func showLobbyLoading() {
        let alert = LoadingAlertController(
            progressText: .toLobby,
            loadAction: { [weak self] in
                await self?.viewModel?.navigateToLobby()
            },
            errorCompletion: { [weak self] error in
                self?.showFailedAlert(error)
            }
        )
        presentAlert(alert)
    }

    private func showFailedAlert(_ error: Error) {
        let alert = SingleButtonAlertController(titleText: .error(error))
        presentAlert(alert)
    }
}
