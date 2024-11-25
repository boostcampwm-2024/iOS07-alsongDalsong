import UIKit

class ASPanel: UIView {
    private var panelColor: UIColor = .asSystem {
        didSet {
            backgroundColor = panelColor
        }
    }

    init() {
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func updateBackgroundColor(_ color: UIColor) {
        backgroundColor = color
    }
    
    func setTitle(
        title: String,
        titleAlign: NSTextAlignment,
        titleSize: CGFloat
    ) {
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
    }

    private func setupUI() {
        layer.cornerRadius = 12
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 3
        setShadow()
    }
}
