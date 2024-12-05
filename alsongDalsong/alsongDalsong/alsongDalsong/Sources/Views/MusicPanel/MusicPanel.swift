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
    private let player: ASMusicPlayerView
    private let noMusicLabel = UILabel()
    private let titleLabel = UILabel()
    private let artistLabel = UILabel()
    private let labelStack = UIStackView()
    private var cancellables = Set<AnyCancellable>()
    private var viewModel: MusicPanelViewModel? = nil
    private var panelType: MusicPanelType = .large

    init(_ type: MusicPanelType = .large) {
        panelType = type
        player = ASMusicPlayerView(type)
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
                let dataDownloadRepository = DIContainer.shared.resolve(DataDownloadRepositoryProtocol.self)
                self.viewModel = MusicPanelViewModel(
                    music: music,
                    type: panelType,
                    dataDownloadRepository: dataDownloadRepository
                )
                self.player.updateMusicPanel(color: music?.artworkBackgroundColor?.hexToCGColor())
                self.bindViewModel()
                self.titleLabel.text = music?.title ?? "???"
                self.artistLabel.text = music?.artist ?? "????"
            }
            .store(in: &cancellables)
    }

    private func bindWithPlayer() {
        player.onPlayButtonTapped = { [weak self] type in
            self?.viewModel?.togglePlayPause(type)
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
