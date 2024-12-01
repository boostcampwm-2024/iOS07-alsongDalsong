import UIKit

extension UIViewController {
    func presentAlert(_ viewcontrollerToPresent: ASAlertController) {
        present(viewcontrollerToPresent, animated: true, completion: nil)
    }
}
