import UIKit
import ASCacheKit

class ViewController: UIViewController {
    private let button: UIButton = {
        let button = UIButton()
        button.adjustsImageWhenHighlighted = false
        button.setBackgroundImage(UIImage(named: "fake"), for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        let action = UIAction(handler: {_ in
            let alert = UIAlertController(title: "페이크다!", message: "힝! 속았찌?", preferredStyle: .alert)

            let yes = UIAlertAction(title: "속았음", style: .default, handler: nil)
            let no = UIAlertAction(title: "안 속았음", style: .destructive, handler: nil)
            no.isEnabled = false

            alert.addAction(yes)
            alert.addAction(no)

            self.present(alert, animated: true)
        })
        button.addAction(action, for: .touchUpInside)
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        button.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}
