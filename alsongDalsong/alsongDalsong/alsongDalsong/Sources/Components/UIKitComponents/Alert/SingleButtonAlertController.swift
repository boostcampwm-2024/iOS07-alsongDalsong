import UIKit

final class SingleButtonAlertController: ASAlertController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStyle()
    }
    
    func setupStyle() {
        setTitle()
        setButtonStackView()
        setDoneButton()
    }
    
    convenience init(
        titleText: ASAlertText.Title,
        doneButtonTitle: ASAlertText.ButtonText = .confirm,
        doneButtonCompletion: ((String) -> Void)? = nil
    ) {
        self.init()
        self.titleText = titleText
        self.doneButtonTitle = doneButtonTitle
        self.doneButtonCompletion = doneButtonCompletion

        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
}
