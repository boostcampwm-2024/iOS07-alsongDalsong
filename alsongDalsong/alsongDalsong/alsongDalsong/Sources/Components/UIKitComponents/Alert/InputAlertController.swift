import UIKit

final class InputAlertController: ASAlertController {
    var textField = ASTextField()
    var textFieldPlaceholder: ASAlertText.Placeholder?
    var textMaxCount: Int = 6
    var isUppercased: Bool = false
    var text: String {
        textField.text ?? ""
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStyle()
    }

    func setupStyle() {
        setTitle()
        setTextField()
        setButtonStackView()
        setSecondaryButton()
        setPrimaryButton()
    }

    override func setPrimaryButton() {
        super.setPrimaryButton()
        primaryButton.addAction(UIAction { [weak self] _ in
            self?.primaryButtonAction?(self?.text ?? "")
        }, for: .touchUpInside)
    }

    override func setSecondaryButton() {
        super.setSecondaryButton()
        secondaryButton.addAction(UIAction { [weak self] _ in
            self?.secondaryButtonAction?()
        }, for: .touchUpInside)
    }

    private func setTextField() {
        textField.setConfiguration(placeholder: textFieldPlaceholder?.description)
        stackView.addArrangedSubview(textField)
        if isUppercased {
            textField.delegate = self
        }
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            textField.heightAnchor.constraint(equalToConstant: 44),
        ])
        textField.heightAnchor.constraint(equalToConstant: 43).priority = .defaultHigh
    }

    convenience init(
        titleText: ASAlertText.Title,
        primaryButtonText: ASAlertText.ButtonText = .done,
        secondaryButtonText: ASAlertText.ButtonText = .cancel,
        textFieldPlaceholder: ASAlertText.Placeholder,
        isUppercased: Bool = false,
        reversedColor: Bool = false,
        primaryButtonAction: ((String) -> Void)? = nil,
        secondaryButtonAction: (() -> Void)? = nil
    ) {
        self.init()
        self.titleText = titleText
        self.textFieldPlaceholder = textFieldPlaceholder
        self.primaryButtonText = primaryButtonText
        self.secondaryButtonText = secondaryButtonText
        self.reversedColor = reversedColor
        self.primaryButtonAction = primaryButtonAction
        self.secondaryButtonAction = secondaryButtonAction
        self.isUppercased = isUppercased

        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
}

extension InputAlertController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let uppercaseString = string.uppercased()

        if let text = textField.text,
           let textRange = Range(range, in: text)
        {
            let updatedText = text.replacingCharacters(in: textRange, with: uppercaseString)
            if updatedText.count <= textMaxCount {
                textField.text = updatedText
            }
            return false
        }

        return true
    }
}
