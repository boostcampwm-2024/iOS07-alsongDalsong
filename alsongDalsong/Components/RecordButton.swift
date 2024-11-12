import UIKit

class RecordButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        widthAnchor.constraint(equalToConstant: 64).isActive = true
        heightAnchor.constraint(equalToConstant: 64).isActive = true
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 64, height: 64)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.size.width / 2
    }
    
    func setupButton() {
        backgroundColor = .red
        layer.borderWidth = 5
        layer.borderColor = UIColor.white.cgColor
    }
}

