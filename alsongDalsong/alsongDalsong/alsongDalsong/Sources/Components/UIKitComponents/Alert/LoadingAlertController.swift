import UIKit

final class LoadingAlertController: ASAlertController {
    var load: (() async throws -> Void)?
    var errorCompletion: ((Error) -> Void)?
    var progressText: ASAlertText.ProgressText?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStyle()
    }

    override func alertViewWidthConstraint() -> NSLayoutConstraint {
        return alertView.widthAnchor.constraint(equalToConstant: 232)
    }

    func setupStyle() {
        setProgressView()
        setProgressText()
    }

    func setProgressView() {
        stackView.addArrangedSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.startAnimating()
        progressView.style = .large
        progressView.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 12).isActive = true
        progressView.hidesWhenStopped = true
        Task {
            guard let load else { return }
            do {
                try await load()
                dismiss(animated: true)
            } catch {
                dismiss(animated: true) { [weak self] in
                    self?.errorCompletion?(error)
                }
            }
        }
    }

    private func setProgressText() {
        let progressLabel = UILabel()
        progressLabel.text = progressText?.description
        progressLabel.font = .font(forTextStyle: .title2)
        progressLabel.textColor = .label
        stackView.addArrangedSubview(progressLabel)
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.adjustsFontSizeToFitWidth = true
        progressLabel.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 12).isActive = true
    }

    convenience init(
        progressText: ASAlertText.ProgressText,
        loadAction: (() async throws -> Void)? = nil,
        errorCompletion: ((Error) -> Void)? = nil
    ) {
        self.init()
        self.progressText = progressText
        self.load = loadAction
        self.errorCompletion = errorCompletion

        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
}
