import UIKit

final class DefaultAlertController: ASAlertController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStyle()
    }
    
    func setupStyle() {
        setTitle()
        setButtonStackView()
        setCancelButton()
        setDoneButton()
    }
    
    convenience init(
        titleText: ASAlertText.Title,
        doneButtonTitle: ASAlertText.ButtonText = .done,
        cancelButtonTitle: ASAlertText.ButtonText = .cancel,
        doneButtonCompletion: ((String) -> Void)? = nil,
        cancelButtonTitleCompletion: (() -> Void)? = nil
    ) {
        self.init()
        self.titleText = titleText
        self.doneButtonTitle = doneButtonTitle
        self.cancelButtonTitle = cancelButtonTitle
        self.doneButtonCompletion = doneButtonCompletion
        cancelButtonCompletion = cancelButtonTitleCompletion

        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
}
