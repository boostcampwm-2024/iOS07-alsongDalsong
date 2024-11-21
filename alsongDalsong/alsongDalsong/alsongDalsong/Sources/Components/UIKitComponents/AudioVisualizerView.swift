import Combine
import UIKit

final class AudioVisualizerView: UIView {
    // TODO: Button을 누르면 ViewModel에 존재하는 ASPlayer가 실행되고 Button의 이미지 변경
    // + ViewModel에서 @Published로 가지고 있는 amplitude를 구독해 변경이 발생할 시, VC에서 updateWaveFormView 메서드 호출
    private var startButton = UIButton()
    private var waveFormView = WaveFormView()
    private var customBackgroundColor: UIColor = .asMint
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        super.init(frame: .zero)
        setupButton()
        setupWaveFormView()
        addSubViews()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
        setupWaveFormView()
        addSubViews()
        setupLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setupView()
    }

    func changeBackgroundColor(color: UIColor) {
        customBackgroundColor = color
    }

    private func setupButton() {
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        let playImage = UIImage(systemName: "play.fill", withConfiguration: config)
        startButton.setImage(playImage, for: .normal)
        startButton.tintColor = UIColor.white
    }

    private func setupWaveFormView() {
        waveFormView.drawVisualizerCircles()
    }

    private func setupView() {
        layer.cornerRadius = 12
        layer.backgroundColor = customBackgroundColor.cgColor
    }

    private func addSubViews() {
        addSubview(startButton)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(waveFormView)
        waveFormView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            startButton.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            startButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            startButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            startButton.trailingAnchor.constraint(equalTo: waveFormView.leadingAnchor, constant: -12),

            waveFormView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            waveFormView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            waveFormView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
        ])
    }

    func bind(
        to dataSource: Published<Float>.Publisher
    ) {
        dataSource
            .receive(on: DispatchQueue.main)
            .sink { [weak self] amplitude in
                self?.updateWaveForm(amplitude: CGFloat(amplitude))
            }
            .store(in: &cancellables)
    }
    
    func updateWaveForm(amplitude: CGFloat) {
        waveFormView.updateVisualizerView(with: amplitude)
    }

    func stopWaveForm() {
        waveFormView.removeVisualizerCircles()
    }
}

final class WaveFormView: UIView {
    var columnWidth: CGFloat?
    var columns: [CAShapeLayer] = []
    var amplitudesHistory: [CGFloat] = []
    let numOfColumns: Int

    override class func awakeFromNib() {
        super.awakeFromNib()
    }

    init(numOfColumns: Int = 43) {
        self.numOfColumns = numOfColumns
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        numOfColumns = 43
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        drawVisualizerCircles()
    }

    /// 파형의 기본 틀을 그립니다.
    func drawVisualizerCircles() {
        amplitudesHistory = Array(repeating: 0, count: numOfColumns)
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
            circleLayer.fillColor = UIColor.asShadow.cgColor

            layer.addSublayer(circleLayer)
            columns.append(circleLayer)
            startingPointX += 2 * diameter
        }
    }

    /// 그려진 파형을 모두 삭제합니다.
    fileprivate func removeVisualizerCircles() {
        for column in columns {
            column.removeFromSuperlayer()
        }

        columns.removeAll()
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

    /// 오른쪽에서 파형이 시작
    fileprivate func updateVisualizerView(with amplitude: CGFloat) {
        guard columns.count == numOfColumns else { return }
        amplitudesHistory.append(amplitude)
        amplitudesHistory.removeFirst()

        for i in 0 ..< columns.count {
            columns[i].path = computeNewPath(for: columns[i], with: amplitudesHistory[i])
            if amplitudesHistory[i] != 0 {
                columns[i].fillColor = UIColor.white.cgColor
            }
        }
    }

    /// 왼쪽에서 파형이 시작
    fileprivate func reverseUpdateVisualizerView(with amplitude: CGFloat) {
        guard columns.count == numOfColumns else { return }
        amplitudesHistory.insert(amplitude, at: 0)
        amplitudesHistory.removeLast()

        for i in 0 ..< columns.count {
            columns[i].path = computeNewPath(for: columns[i], with: amplitudesHistory[i])
            if amplitudesHistory[i] != 0 {
                columns[i].fillColor = UIColor.white.cgColor
            }
        }
    }
}
