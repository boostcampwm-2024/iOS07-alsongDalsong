import UIKit

final class NicknamePanel: UIView {
    private var panel = ASPanel()
    private var textField = ASTextField()
    private var title = UILabel()
    private var nickNameTextFieldMaxCount = 12
    
    var text: String? {
        get {
            return textField.text
        }
        set {
            textField.text = newValue
        }
    }
    
    init() {
        super.init(frame: .zero)
        setupUI()
        setupLayout()
        textField.delegate = self
        text = textField.text
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTextField(placeholder: String) {
        textField.setConfiguration(placeholder: placeholder)
    }
    
    private func setupUI() {
        title.text = Constants.nickNameTitle
        title.textColor = .asBlack
        title.textAlignment = .left
        title.font = .font(forTextStyle: .title2)
        title.numberOfLines = 0
        title.lineBreakMode = .byWordWrapping
        title.sizeToFit()
        panel.addSubview(title)
        panel.addSubview(textField)
        addSubview(panel)
    }
    
    private func setupLayout() {
        panel.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
        title.setContentHuggingPriority(.required, for: .vertical)
        title.setContentHuggingPriority(.required, for: .horizontal)
        title.setContentCompressionResistancePriority(.required, for: .vertical)
        title.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        NSLayoutConstraint.activate([
            panel.leadingAnchor.constraint(equalTo: leadingAnchor),
            panel.trailingAnchor.constraint(equalTo: trailingAnchor),
            panel.topAnchor.constraint(equalTo: topAnchor),
            panel.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            title.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 16),
            title.trailingAnchor.constraint(equalTo: panel.trailingAnchor),
            title.topAnchor.constraint(equalTo: panel.topAnchor, constant: 16),
            title.bottomAnchor.constraint(equalTo: textField.topAnchor, constant: -16),
            
            textField.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -16),
            textField.bottomAnchor.constraint(equalTo: panel.bottomAnchor, constant: -16),
        ])
    }
}

extension NicknamePanel: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text,
              let stringRange = Range(range, in: currentText)
        else {
            return false
        }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        guard updatedText.count <= nickNameTextFieldMaxCount else {
            return false
        }
        let allowedCharacters = CharacterSet.alphanumerics.union(.whitespaces)
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
}

extension NicknamePanel {
    enum Constants {
        static let nickNameTitle = "닉네임"
    }
}
