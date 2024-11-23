import ASContainer
import ASEntity
import ASRepository
import Combine
import UIKit

final class MusicPanel: UIView {
    private var music: Music?
    private let panel = ASPanel()
    private let player = ASMusicPlayer()
    private let titleLabel = UILabel()
    private let artistLabel = UILabel()
    private var cancellables = Set<AnyCancellable>()
    private let musicRepository: MusicRepositoryProtocol

    init() {
        musicRepository = DIContainer.shared.resolve(MusicRepositoryProtocol.self)
        super.init(frame: .zero)
        setupUI()
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func onPlayButtonTapped(completion: ((_ isPlaying: Bool) -> Void)?) {
        player.onPlayButtonTapped = { isPlaying in
            completion?(isPlaying)
        }
    }

    func bind(
        to dataSource: Published<Music?>.Publisher
    ) {
        dataSource
            .receive(on: DispatchQueue.main)
            .sink { [weak self] music in
                self?.music = music
                self?.getArtworkData()
                self?.titleLabel.text = music?.title ?? "???"
                self?.artistLabel.text = music?.artist ?? "????"
                self?.setNeedsLayout()
            }
            .store(in: &cancellables)
    }

    private func setupUI() {
        addSubview(panel)
        addSubview(player)
        addSubview(titleLabel)
        addSubview(artistLabel)

        panel.panelColor = .asSystem
        titleLabel.font = .font(forTextStyle: .title3)
        artistLabel.font = .font(forTextStyle: .title3)
        titleLabel.textColor = .label
        artistLabel.textColor = .secondaryLabel
    }

    private func setupLayout() {
        panel.translatesAutoresizingMaskIntoConstraints = false
        player.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        artistLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            panel.topAnchor.constraint(equalTo: topAnchor),
            panel.bottomAnchor.constraint(equalTo: bottomAnchor),
            panel.leadingAnchor.constraint(equalTo: leadingAnchor),
            panel.trailingAnchor.constraint(equalTo: trailingAnchor),

            player.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            player.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            player.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            player.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -12),

            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            artistLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            artistLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
        ])
    }

    private func getArtworkData() {
        guard let artworkUrl = music?.artworkUrl else { return player.updateImage(with: nil) }
        musicRepository.getMusicData(url: artworkUrl)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                    case .finished:
                        break
                    case let .failure(error):
                        print(error.localizedDescription)
                }
            } receiveValue: { [weak self] artwork in
                self?.player.updateImage(with: artwork)
            }
            .store(in: &cancellables)
    }
}

private final class ASMusicPlayer: UIView {
    private var backgroundImageView = UIImageView()
    private var blurView = UIVisualEffectView()
    private var playButton = UIButton()
    var onPlayButtonTapped: ((_ isPlaying: Bool) -> Void)?

    init() {
        super.init(frame: .zero)
        setupUI()
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateImage(with image: Data?) {
        if let image, !image.isEmpty {
            backgroundImageView.image = UIImage(data: image)
        } else {
            let gradientLayer = makeGradientLayer()
            backgroundImageView.layer.addSublayer(gradientLayer)
        }
    }

    private func setupUI() {
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.layer.cornerRadius = 15
        setupButton()
        setupBlurView()
        addSubview(backgroundImageView)
        addSubview(blurView)
        addSubview(playButton)
    }

    private func setupLayout() {
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        blurView.translatesAutoresizingMaskIntoConstraints = false
        playButton.translatesAutoresizingMaskIntoConstraints = false

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

            playButton.leadingAnchor.constraint(equalTo: backgroundImageView.leadingAnchor, constant: 92),
            playButton.trailingAnchor.constraint(equalTo: backgroundImageView.trailingAnchor, constant: -92),
            playButton.centerYAnchor.constraint(equalTo: backgroundImageView.centerYAnchor),
        ])
    }

    private func didButtonTapped() {
        playButton.isSelected.toggle()
        onPlayButtonTapped?(!playButton.isSelected)
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
        let configuration = UIImage.SymbolConfiguration(pointSize: 60)
        let playImage = UIImage(systemName: "play.fill", withConfiguration: configuration)
        let stopImage = UIImage(systemName: "stop.fill", withConfiguration: configuration)
        playButton.setImage(playImage, for: .normal)
        playButton.setImage(stopImage, for: .selected)
        playButton.tintColor = .white
        playButton.adjustsImageWhenHighlighted = false
        playButton.addAction(UIAction { [weak self] _ in
            self?.didButtonTapped()
        }, for: .touchUpInside)
        playButton.addAction(UIAction { [weak self] _ in
            self?.buttonTouchDown()
        }, for: .touchDown)
        playButton.addAction(UIAction { [weak self] _ in
            self?.buttonTouchUp()
        }, for: [.touchUpInside, .touchCancel, .touchUpOutside])
    }

    private func buttonTouchDown() {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut) {
            self.playButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }

    private func buttonTouchUp() {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut) {
            self.playButton.transform = .identity
        }
    }

    private func setupBlurView() {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.layer.cornerRadius = 15
        blurView.clipsToBounds = true
        blurView.alpha = 0.6
    }
}
