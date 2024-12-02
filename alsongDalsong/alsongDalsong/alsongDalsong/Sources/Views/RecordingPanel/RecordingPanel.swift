import Combine
import UIKit

final class RecordingPanel: UIView {
    private var playButton = UIButton()
    private var waveFormView = WaveForm()
    private var customBackgroundColor: UIColor
    private var cancellables = Set<AnyCancellable>()
    private let viewModel = RecordingPanelViewModel()
    var onRecordingFinished: ((Data) -> Void)?

    init(_ color: UIColor = .asMint) {
        customBackgroundColor = color
        super.init(frame: .zero)
        setupButton()
        setupUI()
        setupLayout()
        bindViewModel()
    }

    required init?(coder: NSCoder) {
        customBackgroundColor = .asMint
        super.init(coder: coder)
        setupUI()
        setupLayout()
        setupButton()
    }

    func bind(
        to dataSource: Published<Bool>.Publisher
    ) {
        dataSource
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isRecording in
                if isRecording {
                    self?.reset()
                    self?.viewModel.startRecording()
                }
            }
            .store(in: &cancellables)
    }

    private func bindViewModel() {
        viewModel.$recordedData
            .filter { $0 != nil }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] recordedData in
                self?.onRecordingFinished?(recordedData ?? Data())
            }
            .store(in: &cancellables)
        viewModel.$recorderAmplitude
            .receive(on: DispatchQueue.main)
            .sink { [weak self] amplitude in
                self?.updateWaveForm(amplitude: CGFloat(amplitude))
            }
            .store(in: &cancellables)
        viewModel.$buttonState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.updateButtonImage(with: state)
                self?.updateWaveForm(state: state)
            }
            .store(in: &cancellables)
        viewModel.$playIndex
            .receive(on: DispatchQueue.main)
            .sink { [weak self] index in
                guard let index else { return }
                self?.updateWaveForm(index: index)
            }
            .store(in: &cancellables)
    }

    private func updateButtonImage(with state: AudioButtonState) {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.curveEaseOut],
            animations: { [weak self] in
                self?.playButton.transform = .identity
            }, completion: { [weak self] _ in
                self?.playButton.configuration?.baseForegroundColor = state.color
                self?.playButton.configuration?.image = state.symbol
            }
        )
    }

    private func setupButton() {
        var buttonConfiguration = UIButton.Configuration.borderless()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        buttonConfiguration.image = viewModel.buttonState.symbol
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

    private func didButtonTapped() {
        viewModel.togglePlayPause()
    }

    private func setupUI() {
        layer.cornerRadius = 12
        layer.backgroundColor = customBackgroundColor.cgColor
        addSubview(playButton)
        addSubview(waveFormView)
    }

    private func setupLayout() {
        playButton.translatesAutoresizingMaskIntoConstraints = false
        waveFormView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playButton.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            playButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            playButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            playButton.widthAnchor.constraint(equalToConstant: 32),

            waveFormView.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 12),
            waveFormView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            waveFormView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            waveFormView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
        ])
    }

    private func updateWaveForm(amplitude: CGFloat) {
        waveFormView.updateAmplitude(with: amplitude)
    }

    private func updateWaveForm(index: Int) {
        waveFormView.updatePlayingIndex(index)
    }

    private func updateWaveForm(state: AudioButtonState) {
        if state == .idle { waveFormView.resetColor() }
    }

    private func reset() {
        waveFormView.resetView()
    }
}

private final class WaveForm: UIView {
    private var columnWidth: CGFloat?
    private var columns: [CAShapeLayer] = []
    private let numOfColumns: Int
    private var count: Int = 0

    override class func awakeFromNib() {
        super.awakeFromNib()
    }

    init(numOfColumns: Int = 48) {
        self.numOfColumns = numOfColumns
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        numOfColumns = 48
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if columns.isEmpty {
            drawVisualizerCircles()
        }
    }

    func resetView() {
        removeVisualizerCircles()
    }

    private func drawVisualizerCircles() {
        let diameter = bounds.width / CGFloat(2 * numOfColumns + 1)
        columnWidth = diameter
        let startingPointY = bounds.midY - diameter / 2
        var startingPointX = bounds.minX + diameter

        for _ in 0 ..< numOfColumns {
            let circleOrigin = CGPoint(x: startingPointX, y: startingPointY)
            let circleSize = CGSize(width: diameter, height: diameter)
            let circle = UIBezierPath(roundedRect: CGRect(origin: circleOrigin, size: circleSize), cornerRadius: diameter / 2)

            let circleLayer = CAShapeLayer()
            circleLayer.path = circle.cgPath
            circleLayer.fillColor = UIColor.white.cgColor

            layer.addSublayer(circleLayer)
            columns.append(circleLayer)
            startingPointX += 2 * diameter
        }
    }

    private func removeVisualizerCircles() {
        for column in columns {
            column.removeFromSuperlayer()
        }
        count = 0
        columns.removeAll()
    }

    fileprivate func resetColor() {
        for column in columns {
            column.fillColor = UIColor.white.cgColor
        }
    }

    fileprivate func updatePlayingIndex(_ index: Int) {
        columns[index].fillColor = UIColor.black.cgColor
    }

    fileprivate func updateAmplitude(with amplitude: CGFloat, direction: Direction = .LTR) {
        guard columns.count == numOfColumns, count < numOfColumns else { return }
        let index = direction == .LTR ? count : numOfColumns - count - 1
        columns[index].path = computeNewPath(for: columns[index], with: amplitude)
        columns[index].fillColor = UIColor.white.cgColor
        count += 1
    }

    private func computeNewPath(for layer: CAShapeLayer, with amplitude: CGFloat) -> CGPath {
        let width = columnWidth ?? 8.0
        let maxHeightGain = bounds.height - 3 * width
        let heightGain = maxHeightGain * amplitude
        let newHeight = width + heightGain
        let newOrigin = CGPoint(x: layer.path?.boundingBox.origin.x ?? 0,
                                y: (layer.superlayer?.bounds.midY ?? 0) - (newHeight / 2))
        let newSize = CGSize(width: width, height: newHeight)

        return UIBezierPath(roundedRect: CGRect(origin: newOrigin, size: newSize), cornerRadius: width / 2).cgPath
    }
}

extension WaveForm {
    enum Direction {
        case RTL, LTR
    }
}
