import Combine
import UIKit

final class ProgressBar: UIView {
    private let progressBar = UIView()
    private var cancellables = Set<AnyCancellable>()
    private var targetDate: Date?
    private var progressBarWidthConstraint: NSLayoutConstraint?

    typealias CompletionHandler = () -> Void
    private var completionHandler: CompletionHandler?
    private var isCancelled = false

    init() {
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(
        to dataSource: Published<Date?>.Publisher
    ) {
        dataSource
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newDate in
                self?.targetDate = newDate
                self?.startProgressAnimation()
            }
            .store(in: &cancellables)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setupProgressBar()
    }

    func setCompletionHandler(_ handler: @escaping CompletionHandler) {
        completionHandler = handler
    }

    func cancelCompletion() {
        isCancelled = true
    }

    private func setupProgressBar() {
        progressBar.backgroundColor = .asYellow
        addSubview(progressBar)

        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBarWidthConstraint = progressBar.widthAnchor.constraint(equalToConstant: bounds.width)
        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: topAnchor),
            progressBar.bottomAnchor.constraint(equalTo: bottomAnchor),
            progressBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressBarWidthConstraint!,
        ])
    }

    private func startProgressAnimation() {
        guard let targetDate else { return }
        let timeInterval = targetDate.timeIntervalSince(Date.now)
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()

        UIView.animate(
            withDuration: timeInterval,
            delay: 0,
            options: .curveLinear,
            animations: {
                self.progressBarWidthConstraint?.constant = 0
                self.layoutIfNeeded()
            },
            completion: { _ in
                if !self.isCancelled {
                    self.completionHandler?()
                    return
                }
            }
        )
    }
}
