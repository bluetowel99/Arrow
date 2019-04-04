
import UIKit

class ARSlideMenuNavigationController: UINavigationController {
    
    var slideMenuDelegate: ARSlideMenuNavigationControllerDelegate?
    
}

// MARK: - ARSlideMenuSideControllerDelegate Implementation

extension ARSlideMenuNavigationController: ARSlideMenuSideViewControllerDelegate {
    
    public func slideMenuPushViewController(sideController: ARSlideMenuSideViewController, viewController: UIViewController, animated: Bool) {
        pushViewController(viewController, animated: animated)
        slideMenuDelegate?.slideMenuCollapseSidePanels()
    }
    
}

// MARK: - ARSlideMenuNavigationControllerDelegate Protocol

protocol ARSlideMenuNavigationControllerDelegate {
    
    func slideMenuToggleLeftPanel()
    func slideMenuToggleRightPanel()
    func slideMenuCollapseSidePanels()
    
}
