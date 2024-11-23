import UIKit

class ASAlertController: UIViewController {
    private var alertView = ASPanel()
    private var textField = ASTextField()
    private var doneButton = ASButton()
    private var cancelButton = ASButton()
    // Alert창에 입력한 text
    var text: String {
        textField.text ?? ""
    }
    
    private var titleText: String = ""
    private var textFieldPlaceholder: String = ""
    private var doneButtonTitle: String = ""
    private var cancelButtonTitle: String = ""
    private var isUppercased: Bool = false
    
    var doneButtonCompletion: (() -> Void)?
    var cancelButtonCompletion: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI(titleText: titleText, textFieldPlaceholder: textFieldPlaceholder, doneButtonTitle: doneButtonTitle, cancelButtonTitle: cancelButtonTitle)
        setupLayout()
        
        if isUppercased {
            textField.delegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            self.alertView.transform = .identity
        }
    }
    
    private func setupUI(titleText: String, textFieldPlaceholder: String, doneButtonTitle: String, cancelButtonTitle: String) {
        view.backgroundColor = .black.withAlphaComponent(0.3)
        alertView.setConfiguration(title: titleText, titleAlign: .center, titleSize: 24)
        alertView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        alertView.backgroundColor = .asLightGray
        alertView.layer.borderWidth = 0
        view.addSubview(alertView)
        
        textField.setConfiguration(placeholder: textFieldPlaceholder)
        alertView.addSubview(textField)
        
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
        textField.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            alertView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alertView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            alertView.widthAnchor.constraint(equalToConstant: 345),
            alertView.heightAnchor.constraint(equalToConstant: 180),
            
            textField.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 12),
            textField.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -12),
            textField.topAnchor.constraint(equalTo: alertView.topAnchor, constant: 56),
            textField.heightAnchor.constraint(equalToConstant: 43),
            
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

extension ASAlertController {
    convenience init(titleText: String, doneButtonTitle: String, cancelButtonTitle: String, textFieldPlaceholder: String, isUppercased: Bool = false) {
        self.init()
        self.titleText = titleText
        self.textFieldPlaceholder = textFieldPlaceholder
        self.doneButtonTitle = doneButtonTitle
        self.cancelButtonTitle = cancelButtonTitle
        self.isUppercased = isUppercased
        
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overFullScreen
    }
}

extension ASAlertController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let uppercaseString = string.uppercased()
        if string == uppercaseString {
            return true
        } else {
            if let text = textField.text,
               let textRange = Range(range, in: text)
            {
                let updatedText = text.replacingCharacters(in: textRange, with: uppercaseString)
                textField.text = updatedText
            }
            return false
        }
    }
}
