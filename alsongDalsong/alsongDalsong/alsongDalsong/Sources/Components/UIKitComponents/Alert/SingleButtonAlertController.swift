import UIKit

final class SingleButtonAlertController: ASAlertController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStyle()
    }
    
    func setupStyle() {
        setTitle()
        setButtonStackView()
        setPrimaryButton()
    }
    
    override func setPrimaryButton() {
        super.setPrimaryButton()
        primaryButton.addAction(UIAction { [weak self] _ in
            self?.primaryButtonAction?("")
        }, for: .touchUpInside)
    }
    
    convenience init(
        titleText: ASAlertText.Title,
        primaryButtonText: ASAlertText.ButtonText = .confirm,
        primaryButtonAction: ((String) -> Void)? = nil
    ) {
        self.init()
        self.titleText = titleText
        self.primaryButtonText = primaryButtonText
        self.primaryButtonAction = primaryButtonAction

        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
}
