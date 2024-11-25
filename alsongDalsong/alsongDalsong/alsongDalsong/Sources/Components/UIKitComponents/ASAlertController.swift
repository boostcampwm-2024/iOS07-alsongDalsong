import UIKit

class ASAlertController: UIViewController {
    private var alertView = ASPanel()
    private var stackView = UIStackView()
    private var buttonStackView = UIStackView()
    // Alert창에 입력한 text
    var text: String {
        textField.text ?? ""
    }

    var textField = ASTextField()
    private var titleText: String = ""
    private var textFieldPlaceholder: String = ""
    private var doneButtonTitle: String = ""
    private var cancelButtonTitle: String = ""
    private var isUppercased: Bool = false
    private var textMaxCount: Int = 6
    private var style: ASAlertStyle = .default

    private var doneButton = ASButton()
    private var cancelButton = ASButton()
    var doneButtonCompletion: ((String) -> Void)?
    var cancelButtonCompletion: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setLayout()
        setupStyle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            self.alertView.transform = .identity
        }
    }

    private func setupUI() {
        view.backgroundColor = .black.withAlphaComponent(0.3)
        alertView.setTitle(title: titleText, titleAlign: .center, titleSize: 24)
        alertView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        alertView.backgroundColor = .asLightGray
        alertView.layer.borderWidth = 0

        stackView.axis = .vertical
        stackView.spacing = 17
        stackView.distribution = .fillProportionally
        stackView.alignment = .center

        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 21
        buttonStackView.distribution = .fillEqually
        buttonStackView.alignment = .center
    }

    private func setLayout() {
        view.addSubview(alertView)
        alertView.addSubview(stackView)
        alertView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            alertView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alertView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            alertView.widthAnchor.constraint(equalToConstant: 345),

            stackView.topAnchor.constraint(equalTo: alertView.topAnchor, constant: 56),
            stackView.bottomAnchor.constraint(equalTo: alertView.bottomAnchor, constant: -16),
            stackView.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -12),

            textField.widthAnchor.constraint(equalToConstant: 321),
            textField.heightAnchor.constraint(equalToConstant: 43),
            buttonStackView.widthAnchor.constraint(equalToConstant: 321),
            doneButton.heightAnchor.constraint(equalToConstant: 40),
            cancelButton.heightAnchor.constraint(equalToConstant: 40),
        ])

        textField.heightAnchor.constraint(equalToConstant: 43).priority = .defaultHigh
        buttonStackView.heightAnchor.constraint(equalToConstant: 56).priority = .defaultHigh
    }

    private func setTitle() {
        alertView.setTitle(title: titleText, titleAlign: .center, titleSize: 24)
        alertView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        alertView.backgroundColor = .asLightGray
        alertView.layer.borderWidth = 0
    }

    private func setTextField() {
        textField.setConfiguration(placeholder: textFieldPlaceholder)
        stackView.addArrangedSubview(textField)
        if isUppercased {
            textField.delegate = self
        }
    }

    private func setDoneButton() {
        stackView.addArrangedSubview(buttonStackView)
        buttonStackView.addArrangedSubview(doneButton)
        doneButton.setConfiguration(systemImageName: "", title: doneButtonTitle, backgroundColor: .asLightSky, textSize: 24)
        doneButton.addAction(UIAction { [weak self] _ in
            self?.doneButtonCompletion?(self?.text ?? "")
            self?.dismiss(animated: true)
        }, for: .touchUpInside)
    }

    private func setCancelButton() {
        if buttonStackView.arrangedSubviews.isEmpty {
            stackView.addArrangedSubview(buttonStackView)
            NSLayoutConstraint.activate([
                buttonStackView.widthAnchor.constraint(equalToConstant: 321),
                buttonStackView.heightAnchor.constraint(equalToConstant: 40),
            ])
        }
        buttonStackView.addArrangedSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setConfiguration(systemImageName: "", title: cancelButtonTitle, backgroundColor: .asLightRed, textSize: 24)
        cancelButton.addAction(UIAction { [weak self] _ in
            self?.cancelButtonCompletion?()
            self?.dismiss(animated: true)
        }, for: .touchUpInside)
    }

    private func setupStyle() {
        switch style {
            case .input:
                setTitle()
                setTextField()
                setDoneButton()
                setCancelButton()
            case .default:
                setTitle()
                setDoneButton()
                setCancelButton()
            case .confirm:
                setTitle()
                setDoneButton()
        }
    }
}

extension ASAlertController {
    convenience init(
        titleText: String,
        doneButtonTitle: String,
        cancelButtonTitle: String,
        textFieldPlaceholder: String = "",
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
        style = .input

        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }

    convenience init(
        titleText: String,
        doneButtonTitle: String,
        cancelButtonTitle: String,
        doneButtonCompletion: ((String) -> Void)? = nil,
        cancelButtonTitleCompletion: (() -> Void)? = nil
    ) {
        self.init()
        self.titleText = titleText
        self.doneButtonTitle = doneButtonTitle
        self.cancelButtonTitle = cancelButtonTitle
        self.doneButtonCompletion = doneButtonCompletion
        cancelButtonCompletion = cancelButtonTitleCompletion
        style = .default

        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }

    convenience init(
        titleText: String,
        doneButtonTitle: String,
        doneButtonCompletion: ((String) -> Void)? = nil
    ) {
        self.init()
        self.titleText = titleText
        self.doneButtonTitle = doneButtonTitle
        self.doneButtonCompletion = doneButtonCompletion
        style = .confirm

        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
}

extension ASAlertController: UITextFieldDelegate {
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

enum ASAlertStyle {
    case input
    case `default`
    case confirm
}
