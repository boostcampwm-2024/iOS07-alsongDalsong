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
        setCancelButton()
        setDoneButton()
    }

    override func setDoneButton() {
        super.setDoneButton()
        doneButton.addAction(UIAction { [weak self] _ in
            self?.doneButtonCompletion?(self?.text ?? "")
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
        doneButtonTitle: ASAlertText.ButtonText = .done,
        cancelButtonTitle: ASAlertText.ButtonText = .cancel,
        textFieldPlaceholder: ASAlertText.Placeholder,
        isUppercased: Bool = false,
        doneButtonCompletion: ((String) -> Void)? = nil,
        cancelButtonTitleCompletion: (() -> Void)? = nil
    ) {
        self.init()
        self.titleText = titleText
        self.textFieldPlaceholder = textFieldPlaceholder
        self.doneButtonTitle = doneButtonTitle
        self.cancelButtonTitle = cancelButtonTitle
        self.doneButtonCompletion = doneButtonCompletion
        cancelButtonCompletion = cancelButtonTitleCompletion
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
