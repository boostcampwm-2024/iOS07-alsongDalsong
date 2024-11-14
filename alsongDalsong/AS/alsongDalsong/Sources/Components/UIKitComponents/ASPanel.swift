import UIKit

class ASPanel: UIView {
    init(title: String, titleAlign: NSTextAlignment, titleSize: CGFloat) {
        super.init(frame: .zero)
        backgroundColor = .white
        
        let label = UILabel()
        label.text = title
        label.textAlignment = titleAlign
        label.font = UIFont.font(.dohyeon, ofSize: titleSize)
        addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 16),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 16),
        ])
        
        layer.cornerRadius = 12
        
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 3
        setShadow()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
