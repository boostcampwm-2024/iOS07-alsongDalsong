import UIKit

final class DefaultAlertController: ASAlertController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStyle()
    }
    
    func setupStyle() {
        setTitle()
        setButtonStackView()
        setSecondaryButton()
        setPrimaryButton()
    }
    
    convenience init(
        titleText: ASAlertText.Title,
        primaryButtonText: ASAlertText.ButtonText = .done,
        secondaryButtonText: ASAlertText.ButtonText = .cancel,
        primaryButtonAction: ((String) -> Void)? = nil,
        secondaryButtonAction: (() -> Void)? = nil
    ) {
        self.init()
        self.titleText = titleText
        self.primaryButtonText = primaryButtonText
        self.secondaryButtonText = secondaryButtonText
        self.primaryButtonAction = primaryButtonAction
        self.secondaryButtonAction = secondaryButtonAction

        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
}
