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
    
    override func setPrimaryButton() {
        super.setPrimaryButton()
        primaryButton.addAction(UIAction { [weak self] _ in
            self?.primaryButtonAction?("")
        }, for: .touchUpInside)
    }
    
    override func setSecondaryButton() {
        super.setSecondaryButton()
        secondaryButton.addAction(UIAction { [weak self] _ in
            self?.secondaryButtonAction?()
        }, for: .touchUpInside)
    }
    
    convenience init(
        titleText: ASAlertText.Title,
        primaryButtonText: ASAlertText.ButtonText = .done,
        secondaryButtonText: ASAlertText.ButtonText = .cancel,
        reversedColor: Bool = false,
        primaryButtonAction: ((String) -> Void)? = nil,
        secondaryButtonAction: (() -> Void)? = nil
    ) {
        self.init()
        self.titleText = titleText
        self.primaryButtonText = primaryButtonText
        self.secondaryButtonText = secondaryButtonText
        self.reversedColor = reversedColor
        self.primaryButtonAction = primaryButtonAction
        self.secondaryButtonAction = secondaryButtonAction

        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
}
