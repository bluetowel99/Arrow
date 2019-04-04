
import UIKit

// MARK: - Child ViewController Extensions

extension UIViewController {

    func addChildViewController(childController: UIViewController, on holderView: UIView) {
        addChildViewController(childController)
        holderView.addSubview(childController.view)
        holderView.setViewConstraints(equalTo: childController.view)
        childController.didMove(toParentViewController: self)
    }

    func addHideKeyboardTapGestRecognizer() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
