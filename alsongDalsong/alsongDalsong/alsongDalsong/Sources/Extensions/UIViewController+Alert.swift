import UIKit

extension UIViewController {
    func showDefaultAlert(
        title: String,
        doneButtonTitle: String,
        cancelButtonTitle: String,
        doneButtonCompletion: @escaping () -> Void,
        cancelButtonCompletion: (() -> Void)? = nil
    ) {
        let alert = ASAlertController2(
            titleText: title,
            doneButtonTitle: doneButtonTitle,
            cancelButtonTitle: cancelButtonTitle
        )
        alert.doneButtonCompletion = doneButtonCompletion
        alert.cancelButtonCompletion = cancelButtonCompletion
        present(alert, animated: true)
    }
    
    func showTextFieldAlert(
        title: String,
        placeholder: String,
        doneButtonTitle: String,
        cancelButtonTitle: String,
        doneButtonCompletion: @escaping () -> Void,
        cancelButtonCompletion: (() -> Void)? = nil
    ) {
        let alert = ASAlertController(
            titleText: title,
            doneButtonTitle: placeholder,
            cancelButtonTitle: doneButtonTitle,
            textFieldPlaceholder: cancelButtonTitle
        )
        alert.doneButtonCompletion = doneButtonCompletion
        alert.cancelButtonCompletion = cancelButtonCompletion
        present(alert, animated: true)
    }
}
