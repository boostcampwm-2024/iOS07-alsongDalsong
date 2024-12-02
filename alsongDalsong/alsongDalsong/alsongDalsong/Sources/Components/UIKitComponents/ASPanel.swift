import UIKit

final class ASPanel: UIView {
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

    private func setupUI() {
        layer.cornerRadius = 12
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 3
        backgroundColor = .asSystem
        setShadow()
    }
}
