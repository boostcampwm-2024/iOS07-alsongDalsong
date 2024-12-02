import ASEntity
import UIKit

final class GuideViewController: UIViewController {
    private let type: GameViewType
    private let titleLabel = GuideLabel(style: .largeTitle)
    private let descriptionLabel = GuideLabel(style: .title2)
    private let cautionLabel = GuideLabel(style: .callout)
    private var imageContainerView: GuideIconView?
    private var completion: (() -> Void)?
    
    init(type: GameViewType, completion: (() -> Void)? = nil) {
        self.type = type
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        setupImageView()
        startAnimation()
    }
    
    private func setupUI() {
        self.navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .asLightGray
        titleLabel.text = type.title
        descriptionLabel.text = type.description
        cautionLabel.isHidden = true

        if let caution = type.caution {
            cautionLabel.isHidden = false
            cautionLabel.text = "* \(caution)"
            cautionLabel.textColor = .systemRed
        }

        if let symbol = type.symbol {
            let image = UIImage(systemName: symbol.systemName)
            let backgroundColor = UIColor(hex: symbol.color)
            let corneredImageView = GuideIconView(
                image: image,
                backgroundColor: backgroundColor
            )
            corneredImageView.translatesAutoresizingMaskIntoConstraints = false
            imageContainerView = corneredImageView
        }
    }
    
    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(cautionLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        cautionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 272),
            titleLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 48),
            descriptionLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            cautionLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            cautionLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            cautionLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
        ])
    }
    
    private func setupImageView(){
        if let imageContainerView {
            view.addSubview(imageContainerView)
            NSLayoutConstraint.activate([
                imageContainerView.widthAnchor.constraint(equalToConstant: 32),
                imageContainerView.heightAnchor.constraint(equalToConstant: 32),
                imageContainerView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor,constant: -4),
                imageContainerView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor,constant: 4),
            ])
        }
        
    }
    
    private func startAnimation() {
        imageContainerView?.animateBounces()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.completion?()
        }
    }
}
