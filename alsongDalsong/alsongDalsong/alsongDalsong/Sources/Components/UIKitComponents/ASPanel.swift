import UIKit

class ASPanel: UIView {
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setConfiguration(
        title: String,
        titleAlign: NSTextAlignment,
        titleSize: CGFloat
    ) {
        backgroundColor = .white
        
        let label = UILabel()
        label.textColor = .asBlack
        label.text = title
        label.textAlignment = titleAlign
        label.font = UIFont.font(.dohyeon, ofSize: titleSize)
        addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 16),
        ])
        
        layer.cornerRadius = 12
        
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 3
        setShadow()
    }
}
