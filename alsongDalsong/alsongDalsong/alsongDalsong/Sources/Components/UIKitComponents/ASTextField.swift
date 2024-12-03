import UIKit

final class ASTextField: UITextField {
    init() {
        super.init(frame: .zero)
    }

    func setConfiguration(
        placeholder: String?,
        backgroundColor: UIColor = .asSystem,
        textSize: CGFloat = 32
    ) {
        layer.cornerRadius = 12

        attributedPlaceholder = NSAttributedString(string: placeholder ?? "", attributes: [.foregroundColor: UIColor.lightGray])
        self.backgroundColor = backgroundColor
        font = UIFont.font(.dohyeon, ofSize: textSize)
        textColor = .asBlack
        attributedText?.addObserver(self, forKeyPath: "string", options: .new, context: nil)
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        leftViewMode = .always
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
