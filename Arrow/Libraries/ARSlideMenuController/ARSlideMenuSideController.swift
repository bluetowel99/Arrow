
import UIKit

class ARSlideMenuSideViewController: ARViewController {
    
    public var delegate: ARSlideMenuSideViewControllerDelegate?
    
}

// MARK: - ARSlideMenuSideViewControllerDelegate Protocol

protocol ARSlideMenuSideViewControllerDelegate {
    
    func slideMenuPushViewController(sideController: ARSlideMenuSideViewController, viewController: UIViewController, animated: Bool)
    
}
