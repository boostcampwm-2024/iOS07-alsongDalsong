import UIKit

class ASAlertController: UIViewController {
    var textField = ASTextField()
    private var titleText: ASAlertText.Title?
    private var textFieldPlaceholder: ASAlertText.Placeholder?
    private var doneButtonTitle: ASAlertText.ButtonText?
    private var cancelButtonTitle: ASAlertText.ButtonText?
    private var isUppercased: Bool = false
    private var textMaxCount: Int = 6
    private var style: ASAlertStyle = .default
    var doneButtonCompletion: ((String) -> Void)?
    var cancelButtonCompletion: (() -> Void)?
    var text: String {
        textField.text ?? ""
    }

    private var alertView = ASPanel()
    private var stackView = UIStackView()
    private var buttonStackView = UIStackView()
    private var titleLabel = UILabel()
    private var doneButton = ASButton()
    private var cancelButton = ASButton()
    private var progressView = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setStackView()
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
        setAlertView()
    }

    private func setAlertView() {
        alertView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        alertView.backgroundColor = .asLightGray
        alertView.layer.borderWidth = 0
        view.addSubview(alertView)
    }

    private func setStackView() {
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        alertView.addSubview(stackView)
    }

    private func setLayout() {
        alertView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            alertView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alertView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            alertView.widthAnchor.constraint(equalToConstant: 345),

            stackView.topAnchor.constraint(equalTo: alertView.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: alertView.bottomAnchor, constant: -16),
            stackView.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -16),
        ])
    }

    private func setTitle() {
        titleLabel.text = titleText?.description
        titleLabel.textAlignment = .center
        titleLabel.font = .font(forTextStyle: .title2)
        stackView.addArrangedSubview(titleLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: stackView.topAnchor),
        ])
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

    private func setButtonStackView() {
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 20
        buttonStackView.distribution = .fillEqually
        buttonStackView.alignment = .center
        stackView.addArrangedSubview(buttonStackView)
        NSLayoutConstraint.activate([
            buttonStackView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
        ])
        buttonStackView.heightAnchor.constraint(equalToConstant: 56).priority = .defaultHigh
    }

    private func setDoneButton() {
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.addArrangedSubview(doneButton)
        doneButton.setConfiguration(
            title: doneButtonTitle?.description,
            backgroundColor: .asLightSky,
            textSize: 24
        )
        doneButton.addAction(UIAction { [weak self] _ in
            self?.doneButtonCompletion?(self?.text ?? "")
            self?.dismiss(animated: true)
        }, for: .touchUpInside)
        doneButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }

    private func setCancelButton() {
        buttonStackView.addArrangedSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setConfiguration(
            title: cancelButtonTitle?.description,
            backgroundColor: .asLightRed,
            textSize: 24
        )
        cancelButton.addAction(UIAction { [weak self] _ in
            self?.cancelButtonCompletion?()
            self?.dismiss(animated: true)
        }, for: .touchUpInside)
        cancelButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }

    private func setProgressView() {
        stackView.addArrangedSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.startAnimating()
        progressView.style = .large
        progressView.hidesWhenStopped = true
    }

    private func setupStyle() {
        switch style {
            case .input:
                setTitle()
                setTextField()
                setButtonStackView()
                setDoneButton()
                setCancelButton()
            case .default:
                setTitle()
                setButtonStackView()
                setDoneButton()
                setCancelButton()
            case .confirm:
                setTitle()
                setButtonStackView()
                setDoneButton()
            case .load:
                setProgressView()
        }
    }
}

// MARK: - Init

extension ASAlertController {
    convenience init(
        style: ASAlertStyle = .input,
        titleText: ASAlertText.Title,
        doneButtonTitle: ASAlertText.ButtonText = .done,
        cancelButtonTitle: ASAlertText.ButtonText = .cancel,
        textFieldPlaceholder: ASAlertText.Placeholder,
        isUppercased: Bool = false,
        doneButtonCompletion: ((String) -> Void)? = nil,
        cancelButtonTitleCompletion: (() -> Void)? = nil
    ) {
        self.init()
        self.style = style
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

    convenience init(
        style: ASAlertStyle = .default,
        titleText: ASAlertText.Title,
        doneButtonTitle: ASAlertText.ButtonText = .done,
        cancelButtonTitle: ASAlertText.ButtonText = .cancel,
        doneButtonCompletion: ((String) -> Void)? = nil,
        cancelButtonTitleCompletion: (() -> Void)? = nil
    ) {
        self.init()
        self.style = style
        self.titleText = titleText
        self.doneButtonTitle = doneButtonTitle
        self.cancelButtonTitle = cancelButtonTitle
        self.doneButtonCompletion = doneButtonCompletion
        cancelButtonCompletion = cancelButtonTitleCompletion

        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }

    convenience init(
        style: ASAlertStyle = .confirm,
        titleText: ASAlertText.Title,
        doneButtonTitle: ASAlertText.ButtonText = .confirm,
        doneButtonCompletion: ((String) -> Void)? = nil
    ) {
        self.init()
        self.style = style
        self.titleText = titleText
        self.doneButtonTitle = doneButtonTitle
        self.doneButtonCompletion = doneButtonCompletion

        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }

    convenience init(_ type: ASAlertStyle) {
        self.init()
        style = type

        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
}

// MARK: - Delegate

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

// MARK: - Alert Type

enum ASAlertStyle {
    case input
    case `default`
    case confirm
    case load
}

enum ASAlertText {
    enum Title: String, CustomStringConvertible {
        case leaveRoom
        case joinRoom
        case joinFailed

        var description: String {
            switch self {
                case .leaveRoom: "방을 나가시겠습니까?"
                case .joinRoom: "게임 입장 코드를 입력하세요"
                case .joinFailed: "참가에 실패하였습니다."
            }
        }
    }

    enum ButtonText: String, CustomStringConvertible {
        case leave
        case cancel
        case done
        case confirm

        var description: String {
            switch self {
                case .leave: "나가기"
                case .cancel: "취소"
                case .done: "완료"
                case .confirm: "확인"
            }
        }
    }

    enum Placeholder: String, CustomStringConvertible {
        case roomNumber

        var description: String {
            switch self {
                case .roomNumber: "000000"
            }
        }
    }
}
