import Combine
import UIKit

final class SubmissionStatusView: UIStackView {
    let label = UILabel()
    
    private var cancellables = Set<AnyCancellable>()

    init() {
        super.init(frame: .zero)
        setupUI()
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 64, height: 30)
    }

    private func setupUI() {
        backgroundColor = .asSystem
        layer.cornerRadius = intrinsicContentSize.height / 2
        clipsToBounds = true
        layer.borderColor = UIColor.label.cgColor
        layer.borderWidth = 2.5
        
        setupStack()
        setupImage()
        setupLabel()
    }

    func bind(
        to dataSource: Published<(submits: String, total: String)>.Publisher
    ) {
        dataSource
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.label.text = "\(status.submits)/\(status.total)"
            }
            .store(in: &cancellables)
    }
    
    private func setupStack() {
        axis = .horizontal
        alignment = .center
        spacing = 2
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 8)
    }

    private func setupImage() {
        let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        let image = UIImage(systemName: "checkmark", withConfiguration: configuration)

        let imageView = UIImageView(image: image)
        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        addArrangedSubview(imageView)
    }
    
    private func setupLabel() {
        label.font = .font(forTextStyle: .body)
        addArrangedSubview(label)
    }
}
