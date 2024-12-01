import ASContainer
import ASEntity
import ASRepositoryProtocol
import Combine
import UIKit

enum MusicPanelType {
    case large, compact
}

final class MusicPanel: UIView {
    private let panel = ASPanel()
    private let player: ASMusicPlayer
    private let noMusicLabel = UILabel()
    private let titleLabel = UILabel()
    private let artistLabel = UILabel()
    private let labelStack = UIStackView()
    private var cancellables = Set<AnyCancellable>()
    private let musicRepository: MusicRepositoryProtocol
    private var viewModel: MusicPanelViewModel? = nil
    private var panelType: MusicPanelType = .large

    init(_ type: MusicPanelType = .large) {
        panelType = type
        musicRepository = DIContainer.shared.resolve(MusicRepositoryProtocol.self)
        player = ASMusicPlayer(type)
        super.init(frame: .zero)
        setupUI()
        setupNoMusicLabel()
        setupLayout()
        setupNoMusicLayout()
        bindWithPlayer()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(to dataSource: Published<Music?>.Publisher) {
        dataSource
            .receive(on: DispatchQueue.main)
            .sink { [weak self] music in
                guard let self else { return }

                if self.panelType == .compact, music == nil {
                    self.noMusicLabel.isHidden = false
                    self.labelStack.isHidden = true
                    self.player.isHidden = true
                } else {
                    self.noMusicLabel.isHidden = true
                    self.labelStack.isHidden = false
                    self.player.isHidden = false
                }

                self.viewModel = MusicPanelViewModel(
                    music: music,
                    musicRepository: self.musicRepository
                )
                self.player.updateMusicPanel(color: music?.artworkBackgroundColor?.hexToCGColor())
                self.bindViewModel()
                self.titleLabel.text = music?.title ?? "???"
                self.artistLabel.text = music?.artist ?? "????"
            }
            .store(in: &cancellables)
    }

    private func bindWithPlayer() {
        player.onPlayButtonTapped = { [weak self] in
            self?.viewModel?.togglePlayPause()
        }
    }

    private func bindViewModel() {
        viewModel?.$artwork
            .receive(on: DispatchQueue.main)
            .sink { [weak self] artwork in
                self?.player.updateMusicPanel(image: artwork)
            }
            .store(in: &cancellables)
        guard let viewModel else { return }
        player.bind(to: viewModel.$buttonState)
    }

    private func setupUI() {
        addSubview(panel)
        addSubview(player)
        addSubview(labelStack)

        titleLabel.textColor = .label
        artistLabel.textColor = .secondaryLabel

        [titleLabel, artistLabel].forEach { label in
            label.font = .font(forTextStyle: .title3)
            label.textAlignment = panelType == .large ? .center : .left
            label.numberOfLines = 1
            label.lineBreakMode = .byTruncatingTail
            label.adjustsFontSizeToFitWidth = false
        }
        setupLabelStack()
    }

    private func setupLayout() {
        panel.translatesAutoresizingMaskIntoConstraints = false
        player.translatesAutoresizingMaskIntoConstraints = false
        labelStack.translatesAutoresizingMaskIntoConstraints = false

        if panelType == .large {
            largeLayout()
        } else {
            compactLayout()
        }
    }

    private func setupNoMusicLayout() {
        noMusicLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noMusicLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            noMusicLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            noMusicLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            noMusicLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
        ])
    }

    private func setupNoMusicLabel() {
        noMusicLabel.text = "정답을 선택해 주세요."
        noMusicLabel.textColor = .secondaryLabel
        noMusicLabel.font = .font(forTextStyle: .title2)
        noMusicLabel.textAlignment = .center
        noMusicLabel.numberOfLines = 0
        noMusicLabel.isHidden = true
        addSubview(noMusicLabel)
    }

    private func setupLabelStack() {
        labelStack.axis = .vertical
        labelStack.spacing = 0
        labelStack.addArrangedSubview(titleLabel)
        labelStack.addArrangedSubview(artistLabel)
    }

    private func largeLayout() {
        NSLayoutConstraint.activate([
            panel.topAnchor.constraint(equalTo: topAnchor),
            panel.bottomAnchor.constraint(equalTo: bottomAnchor),
            panel.leadingAnchor.constraint(equalTo: leadingAnchor),
            panel.trailingAnchor.constraint(equalTo: trailingAnchor),

            player.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            player.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            player.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            player.bottomAnchor.constraint(equalTo: labelStack.topAnchor, constant: -12),

            labelStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            labelStack.widthAnchor.constraint(equalTo: player.widthAnchor, constant: -16),
            labelStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
        ])
    }

    private func compactLayout() {
        NSLayoutConstraint.activate([
            panel.topAnchor.constraint(equalTo: topAnchor),
            panel.bottomAnchor.constraint(equalTo: bottomAnchor),
            panel.leadingAnchor.constraint(equalTo: leadingAnchor),
            panel.trailingAnchor.constraint(equalTo: trailingAnchor),

            player.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            player.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            player.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            player.trailingAnchor.constraint(equalTo: trailingAnchor),

            labelStack.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 8),
            labelStack.widthAnchor.constraint(equalToConstant: 160),
            labelStack.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}

private final class ASMusicPlayer: UIView {
    private var backgroundImageView = UIImageView()
    private var blurView = UIVisualEffectView()
    private var playButton = UIButton()
    private var panelType: MusicPanelType
    var onPlayButtonTapped: (() -> Void)?
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
        } else { compactLayout() }
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
        onPlayButtonTapped?()
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
