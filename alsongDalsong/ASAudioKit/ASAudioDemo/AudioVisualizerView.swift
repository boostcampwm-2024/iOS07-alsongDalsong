import UIKit
import SwiftUI

class AudioVisualizerView: UIView {
    var columnWidth: CGFloat?
    var columns: [CAShapeLayer] = []
    var amplitudesHistory: [CGFloat] = []
    let numOfColumns: Int = 43
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        drawVisualizerCircles()
    }
    
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
            circleLayer.fillColor = UIColor.systemBlue.cgColor
            
            self.layer.addSublayer(circleLayer)
            self.columns.append(circleLayer)
            startingPointX += 2 * diameter
        }
    }
    
    func removeVisualizerCircles() {
        for column in self.columns {
            column.removeFromSuperlayer()
        }
        
        self.columns.removeAll()
    }
    
    private func computeNewPath(for layer: CAShapeLayer, with amplitude: CGFloat) -> CGPath {
        let width = self.columnWidth ?? 8.0
        let maxHeightGain = self.bounds.height - 3 * width
        let heightGain =  maxHeightGain * amplitude
        let newHeight = width + heightGain
        let newOrigin = CGPoint(x: layer.path?.boundingBox.origin.x ?? 0,
                                y: (layer.superlayer?.bounds.midY ?? 0) - (newHeight / 2))
        let newSize = CGSize(width: width, height: newHeight)
        
        return UIBezierPath(roundedRect: CGRect(origin: newOrigin, size: newSize), cornerRadius: width / 2).cgPath
    }
    
    fileprivate func updateVisualizerView(with amplitude: CGFloat) {
        guard self.columns.count == numOfColumns else { return }
        self.amplitudesHistory.append(amplitude)
        self.amplitudesHistory.removeFirst()
        
        for i in 0..<self.columns.count {
            self.columns[i].path = computeNewPath(for: self.columns[i], with: self.amplitudesHistory[i])
        }
    }
}

struct AudioVisualizerViewWrapper: UIViewRepresentable {
    @Binding var amplitude: Float
    
    func makeUIView(context: Context) -> AudioVisualizerView {
        let visualizer = AudioVisualizerView(frame: .zero)
        return visualizer
    }
    
    func updateUIView(_ uiView: AudioVisualizerView, context: Context) {
        uiView.updateVisualizerView(with: CGFloat(amplitude))
    }
}
