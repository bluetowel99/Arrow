
import UIKit

// Solution based on http://stackoverflow.com/questions/35452785/swift-protocol-of-a-particular-class
protocol UIViewControllerType { }
extension UIViewController: UIViewControllerType { }
typealias DismissableUIViewController = UIViewControllerType & DismissableController

protocol DismissableController: class {
    
    var delegate: DismissableControllerDelegate? { get set }
    
}

// MARK: - Dismissable Tab Controller Delegate Definition

protocol DismissableControllerDelegate {
    
    func controllerDidDismiss(controller: UIViewController)
    
}
