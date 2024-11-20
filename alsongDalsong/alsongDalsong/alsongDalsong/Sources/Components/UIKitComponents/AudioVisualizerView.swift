import UIKit

final class AudioVisualizerView: UIView {
    //TODO: Button을 누르면 ViewModel에 존재하는 ASPlayer가 실행되고 Button의 이미지 변경
    // + ViewModel에서 @Published로 가지고 있는 amplitude를 구독해 변경이 발생할 시, VC에서 updateWaveFormView 메서드 호출
    private var startButton = UIButton()
    private var waveFormView = WaveFormView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        self.layer.backgroundColor = color.cgColor
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
        self.layer.cornerRadius = 12
        self.layer.backgroundColor = UIColor.asMint.cgColor
    }
    
    private func addSubViews() {
        addSubview(startButton)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(waveFormView)
        waveFormView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            startButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            startButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16),
            startButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            startButton.trailingAnchor.constraint(equalTo: waveFormView.leadingAnchor, constant: -12),
            
            waveFormView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            waveFormView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
            waveFormView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12)
        ])
    }
    
    func updateWaveForm(amplitude: CGFloat) {
        self.waveFormView.updateVisualizerView(with: amplitude)
    }
    
    func stopWaveForm() {
        self.waveFormView.removeVisualizerCircles()
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
    
    init(frame: CGRect, numOfColumns: Int = 43) {
        self.numOfColumns = numOfColumns
        super.init(frame: frame)
    }
    
    convenience override init(frame: CGRect) {
        self.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        self.numOfColumns = 43
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        drawVisualizerCircles()
    }
    
    /// 파형의 기본 틀을 그립니다.
    func drawVisualizerCircles() {
        self.amplitudesHistory = Array(repeating: 0, count: numOfColumns)
        let diameter = self.bounds.width / CGFloat(2 * numOfColumns + 1)
        self.columnWidth = diameter
        let startingPointY = self.bounds.midY - diameter / 2
        var startingPointX = self.bounds.minX + diameter
        
        for _ in 0 ..< numOfColumns {
            let circleOrigin = CGPoint(x: startingPointX, y: startingPointY)
            let circleSize = CGSize(width: diameter, height: diameter)
            let circle = UIBezierPath(roundedRect: CGRect(origin: circleOrigin, size: circleSize), cornerRadius: diameter / 2)
            
            let circleLayer = CAShapeLayer()
            circleLayer.path = circle.cgPath
            circleLayer.fillColor = UIColor.asShadow.cgColor
            
            self.layer.addSublayer(circleLayer)
            self.columns.append(circleLayer)
            startingPointX += 2 * diameter
        }
    }
    
    /// 그려진 파형을 모두 삭제합니다.
    fileprivate func removeVisualizerCircles() {
        for column in self.columns {
            column.removeFromSuperlayer()
        }
        
        self.columns.removeAll()
    }
    
    private func computeNewPath(for layer: CAShapeLayer, with amplitude: CGFloat) -> CGPath {
        let width = self.columnWidth ?? 8.0
        let maxHeightGain = self.bounds.height - 3 * width
        let heightGain = maxHeightGain * amplitude
        let newHeight = width + heightGain
        let newOrigin = CGPoint(x: layer.path?.boundingBox.origin.x ?? 0,
                                y: (layer.superlayer?.bounds.midY ?? 0) - (newHeight / 2))
        let newSize = CGSize(width: width, height: newHeight)
        
        return UIBezierPath(roundedRect: CGRect(origin: newOrigin, size: newSize), cornerRadius: width / 2).cgPath
    }
    
    /// 오른쪽에서 파형이 시작
    fileprivate func updateVisualizerView(with amplitude: CGFloat) {
        guard self.columns.count == numOfColumns else { return }
        self.amplitudesHistory.append(amplitude)
        self.amplitudesHistory.removeFirst()
        
        for i in 0..<self.columns.count {
            self.columns[i].path = computeNewPath(for: self.columns[i], with: self.amplitudesHistory[i])
            if self.amplitudesHistory[i] != 0 {
                self.columns[i].fillColor = UIColor.white.cgColor
            }
        }
    }
    
    /// 왼쪽에서 파형이 시작
    fileprivate func reverseUpdateVisualizerView(with amplitude: CGFloat) {
        guard self.columns.count == numOfColumns else { return }
        self.amplitudesHistory.insert(amplitude, at: 0)
        self.amplitudesHistory.removeLast()
        
        for i in 0..<self.columns.count {
            self.columns[i].path = computeNewPath(for: self.columns[i], with: self.amplitudesHistory[i])
            if self.amplitudesHistory[i] != 0 {
                self.columns[i].fillColor = UIColor.white.cgColor
            }
        }
    }
}
