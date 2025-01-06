import Foundation
import UIKit

final class WaveForm: UIView {
    private var columnWidth: CGFloat?
    private var columns: [CAShapeLayer] = []
    private let numOfColumns: Int
    private var count: Int = 0
    private var circleColor: UIColor
    private var highlightColor: UIColor

    override class func awakeFromNib() {
        super.awakeFromNib()
    }

    init(numOfColumns: Int = 48, circleColor: UIColor = .white, highlightColor: UIColor = .black) {
        self.numOfColumns = numOfColumns
        self.circleColor = circleColor
        self.highlightColor = highlightColor
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        numOfColumns = 48
        circleColor = .white
        highlightColor = .black
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

    func drawColumns(with amplitudes: [CGFloat]) {
        for amplitude in amplitudes {
            updateAmplitude(with: amplitude)
        }
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
            circleLayer.fillColor = circleColor.cgColor

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

    func resetColor() {
        for column in columns {
            column.fillColor = circleColor.cgColor
        }
    }

    func updatePlayingIndex(_ index: Int) {
        columns[index].fillColor = highlightColor.cgColor
    }

    func updateAmplitude(with amplitude: CGFloat, direction: Direction = .LTR) {
        guard columns.count == numOfColumns, count < numOfColumns else { return }
        let index = direction == .LTR ? count : numOfColumns - count - 1
        columns[index].path = computeNewPath(for: columns[index], with: amplitude)
        columns[index].fillColor = circleColor.cgColor
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
