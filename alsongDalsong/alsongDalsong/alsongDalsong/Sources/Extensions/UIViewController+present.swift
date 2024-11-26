import UIKit

extension UIViewController {
    func presentAlert(_ viewcontrollerToPresent: ASAlertController) {
        present(viewcontrollerToPresent, animated: true, completion: nil)
    }

    func presentLoadingView(_ viewcontrollerToPresent: ASAlertController) {
        present(viewcontrollerToPresent, animated: true, completion: nil)
    }
}
