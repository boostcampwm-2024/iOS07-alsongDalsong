import UIKit

//TODO: - 공통으로 사용할 수 있도록 만들어야할 듯합니다.
final class ASAlertController2: UIViewController {
    private var alertView = ASPanel()
    private var doneButton = ASButton()
    private var cancelButton = ASButton()
    
    private var titleText: String = ""
    private var doneButtonTitle: String = ""
    private var cancelButtonTitle: String = ""
    
    var doneButtonCompletion: (() -> Void)?
    var cancelButtonCompletion: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI(
            titleText: titleText,
            doneButtonTitle: doneButtonTitle,
            cancelButtonTitle: cancelButtonTitle
        )
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            self.alertView.transform = .identity
        }
    }
    
    private func setupUI(
        titleText: String,
        doneButtonTitle: String,
        cancelButtonTitle: String
    ) {
        self.view.backgroundColor = .black.withAlphaComponent(0.3)
        alertView.setConfiguration(title: titleText, titleAlign: .center, titleSize: 24)
        alertView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        alertView.backgroundColor = .asLightGray
        alertView.layer.borderWidth = 0
        view.addSubview(alertView)
        
        doneButton.setConfiguration(systemImageName: "", title: doneButtonTitle, backgroundColor: .asLightSky, textSize: 24)
        cancelButton.setConfiguration(systemImageName: "", title: cancelButtonTitle, backgroundColor: .asLightRed, textSize: 24)
        alertView.addSubview(doneButton)
        alertView.addSubview(cancelButton)
        
        doneButton.addAction(UIAction { [weak self] _ in
            self?.doneButtonCompletion?()
            self?.dismiss(animated: true)
        }, for: .touchUpInside)
        
        cancelButton.addAction(UIAction { [weak self] _ in
            self?.cancelButtonCompletion?()
            self?.dismiss(animated: true)
        }, for: .touchUpInside)
    }
    
    private func setupLayout() {
        alertView.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            alertView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alertView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            alertView.widthAnchor.constraint(equalToConstant: 345),
            alertView.heightAnchor.constraint(equalToConstant: 120),
            
            doneButton.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 12),
            doneButton.bottomAnchor.constraint(equalTo: alertView.bottomAnchor, constant: -24),
            doneButton.widthAnchor.constraint(equalToConstant: 150),
            doneButton.heightAnchor.constraint(equalToConstant: 40),
            
            cancelButton.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -12),
            cancelButton.bottomAnchor.constraint(equalTo: alertView.bottomAnchor, constant: -24),
            cancelButton.widthAnchor.constraint(equalToConstant: 150),
            cancelButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
}

extension ASAlertController2 {
    convenience init(
        titleText: String,
        doneButtonTitle: String,
        cancelButtonTitle: String
    ) {
        self.init()
        self.titleText = titleText
        self.doneButtonTitle = doneButtonTitle
        self.cancelButtonTitle = cancelButtonTitle
        
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overFullScreen
    }
}
