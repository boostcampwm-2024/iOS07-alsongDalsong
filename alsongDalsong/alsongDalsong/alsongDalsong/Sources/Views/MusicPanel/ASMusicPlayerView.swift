import Combine
import UIKit

final class ASMusicPlayerView: UIView {
    private var backgroundImageView = UIImageView()
    private var blurView = UIVisualEffectView()
    private var playButton = UIButton()
    private var panelType: MusicPanelType
    var onPlayButtonTapped: ((MusicPanelType) -> Void)?
    private var cancellables = Set<AnyCancellable>()

    init(_ type: MusicPanelType = .large) {
        panelType = type
        super.init(frame: .zero)
        setupUI()
        setupLayout()
    }

    func bind(
        to dataSource: Published<AudioButtonState>.Publisher
    ) {
        dataSource
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.updateButtonImage(with: state)
            }
            .store(in: &cancellables)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundImageView.layer.sublayers?.forEach { layer in
            if let gradientLayer = layer as? CAGradientLayer {
                gradientLayer.frame = backgroundImageView.bounds
            }
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateMusicPanel(image: Data? = nil, color: CGColor? = nil) {
        if let image, !image.isEmpty {
            backgroundImageView.layer.sublayers?.removeAll()
            backgroundImageView.image = UIImage(data: image)
            return
        }

        if let color {
            backgroundImageView.layer.sublayers?.removeAll()
            backgroundImageView.backgroundColor = UIColor(cgColor: color)
            return
        }
    }

    private func setupUI() {
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.layer.cornerRadius = panelType == .large ? 15 : 5
        setupButton()
        setupBlurView()
        addSubview(backgroundImageView)
        if panelType == .large {
            addSubview(blurView)
        }
        addSubview(playButton)
        let gradientLayer = makeGradientLayer()
        backgroundImageView.layer.addSublayer(gradientLayer)
    }

    private func setupLayout() {
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        blurView.translatesAutoresizingMaskIntoConstraints = panelType == .large
        playButton.translatesAutoresizingMaskIntoConstraints = false

        if panelType == .large {
            largeLayout()
        } else { compactLayout() }
    }

    private func largeLayout() {
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundImageView.heightAnchor.constraint(equalTo: widthAnchor),

            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),

            playButton.centerYAnchor.constraint(equalTo: backgroundImageView.centerYAnchor),
            playButton.centerXAnchor.constraint(equalTo: backgroundImageView.centerXAnchor),
        ])
    }
    
    private func compactLayout() {
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.widthAnchor.constraint(equalTo: heightAnchor),

            playButton.centerYAnchor.constraint(equalTo: backgroundImageView.centerYAnchor),
            playButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
        ])
    }

    private func updateButtonImage(with state: AudioButtonState) {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.curveEaseOut],
            animations: { [weak self] in
                self?.playButton.transform = .identity
            }, completion: { [weak self] _ in
                self?.playButton.configuration?.baseForegroundColor = self?.panelType == .large ? state.color : .asBlack
                self?.playButton.configuration?.image = state.symbol
            }
        )
    }

    private func didButtonTapped() {
        onPlayButtonTapped?(panelType)
    }

    private func makeGradientLayer() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        let colors: [CGColor] = [
            UIColor.asOrange.cgColor,
            UIColor.asYellow.cgColor,
            UIColor.asGreen.cgColor,
        ]
        gradientLayer.frame = backgroundImageView.bounds
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
        return gradientLayer
    }

    private func setupButton() {
        var buttonConfiguration = UIButton.Configuration.borderless()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: panelType == .large ? 60 : 32)
        buttonConfiguration.preferredSymbolConfigurationForImage = imageConfig
        buttonConfiguration.baseForegroundColor = .white
        buttonConfiguration.contentInsets = .zero
        buttonConfiguration.background.backgroundColorTransformer = UIConfigurationColorTransformer { color in
            color.withAlphaComponent(0.0)
        }

        playButton.configurationUpdateHandler = { button in
            UIView.animate(
                withDuration: 0.15,
                delay: 0,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 0.5,
                options: [.allowUserInteraction],
                animations: {
                    if button.isHighlighted {
                        button.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
                    } else {
                        button.transform = .identity
                    }
                }
            )
        }

        playButton.configuration = buttonConfiguration
        playButton.addAction(UIAction { [weak self] _ in
            self?.didButtonTapped()
        }, for: .touchUpInside)
    }

    private func setupBlurView() {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.layer.cornerRadius = 15
        blurView.clipsToBounds = true
        blurView.alpha = 0.6
    }
}
