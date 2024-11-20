import Combine
import UIKit

final class SubmissionStatusView: UIStackView {
    let label = UILabel()
    private var cancellables = Set<AnyCancellable>()

    init() {
        super.init(frame: .zero)
        setupStack()
        setupImage()
        setupLabel()
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 120, height: 48)
    }

    func bind(
        to dataSource: Published<(submits: String, total: String)>.Publisher
    ) {
        dataSource
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.label.text = "\(status.submits) / \(status.total)"
            }
            .store(in: &cancellables)
    }

    func setupStack() {
        axis = .horizontal
        alignment = .center
        spacing = 16
    }

    func setupLabel() {
        label.font = .font(forTextStyle: .largeTitle)
        addArrangedSubview(label)
    }

    func setupImage() {
        let image = UIImage(systemName: "checkmark.square.fill")
        let imageView = UIImageView(image: image)
        imageView.tintColor = .asGreen
        addArrangedSubview(imageView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
}
