import UIKit

class ASAlertController: UIViewController {
    var titleText: ASAlertText.Title?
    var doneButtonTitle: ASAlertText.ButtonText?
    var cancelButtonTitle: ASAlertText.ButtonText?
    var doneButtonCompletion: ((String) -> Void)?
    var cancelButtonCompletion: (() -> Void)?

    var alertView = ASPanel()
    var stackView = UIStackView()
    lazy var buttonStackView = UIStackView()
    lazy var titleLabel = UILabel()
    lazy var doneButton = ASButton()
    lazy var cancelButton = ASButton()
    lazy var progressView = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setStackView()
        setLayout()
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
        alertView.layer.borderWidth = 2.5
        alertView.layer.borderColor = UIColor.asBlack.cgColor
        view.addSubview(alertView)
    }

    private func setStackView() {
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        alertView.addSubview(stackView)
    }

    func alertViewWidthConstraint() -> NSLayoutConstraint {
        return alertView.widthAnchor.constraint(equalToConstant: 345)
    }

    private func setLayout() {
        alertView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            alertView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alertView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            alertViewWidthConstraint(),

            stackView.topAnchor.constraint(equalTo: alertView.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: alertView.bottomAnchor, constant: -16),
            stackView.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -16),
        ])
    }

    func setTitle() {
        titleLabel.text = titleText?.description
        titleLabel.textAlignment = .center
        titleLabel.font = .font(forTextStyle: .title2)
        titleLabel.numberOfLines = 0
        stackView.addArrangedSubview(titleLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: stackView.topAnchor),
        ])
    }

    func setButtonStackView() {
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

    func setDoneButton() {
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.addArrangedSubview(doneButton)
        doneButton.setConfiguration(
            title: doneButtonTitle?.description,
            backgroundColor: .asLightSky,
            textSize: 24
        )
        doneButton.addAction(UIAction { [weak self] _ in
            self?.dismiss(animated: true)
        }, for: .touchUpInside)
        doneButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }

    func setCancelButton() {
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
}

// MARK: - Alert Type

enum ASAlertStyle {
    case input
    case `default`
    case confirm
    case load
}

enum ASAlertText {
    enum Title: CustomStringConvertible {
        case leaveRoom
        case joinRoom
        case joinFailed
        case error(Error)
        case needMorePlayer

        var description: String {
            switch self {
                case .leaveRoom: "방을 나가시겠습니까?"
                case .joinRoom: "게임 입장 코드를 입력하세요"
                case .joinFailed: "참가에 실패하였습니다."
                case let .error(error): "\(error.localizedDescription)\n 잠시후에 다시 시도해주세요"
                case .needMorePlayer: "알쏭달쏭은 여럿이서 할 수록\n재미있는 게임이에요!\n그래도 하시겠어요?"
            }
        }
    }

    enum ButtonText: String, CustomStringConvertible {
        case leave
        case cancel
        case done
        case confirm
        case keep

        var description: String {
            switch self {
                case .leave: "나가기"
                case .cancel: "취소"
                case .done: "완료"
                case .confirm: "확인"
                case .keep: "계속 하기"
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

    enum ProgressText: CustomStringConvertible {
        case joinRoom
        case startGame
        case submitMusic
        case submitHumming
        case nextResult
        var description: String {
            switch self {
                case .joinRoom: "방 정보를 가져오는 중..."
                case .startGame: "게임을 시작하는 중..."
                case .submitMusic: "노래를 전송하는 중..."
                case .submitHumming: "허밍을 전송하는 중..."
                case .nextResult: "다음 결과를 가져오는 중..."
            }
        }
    }
}