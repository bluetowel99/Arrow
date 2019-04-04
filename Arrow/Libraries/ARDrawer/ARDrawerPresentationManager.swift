
import UIKit

final class ARDrawerPresentationManager: NSObject {
    fileprivate let dismissalAnimator = ARDrawerDismissalAnimator()
    fileprivate let presentationAnimator = ARDrawerPresentationAnimator()
    fileprivate var interactionController: ARDrawerInteractiveTransition?
    
    var interactiveDismiss = true
    
    func setupInteractionControllerForDismissal(with drawer: ARDrawer) {
        interactionController = ARDrawerInteractiveTransition(with: drawer)
    }
}

extension ARDrawerPresentationManager: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = ARDrawerPresentationController(presentedViewController: presented, presenting: presenting)
        return presentationController
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentationAnimator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissalAnimator
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if interactiveDismiss {
            return interactionController
        }
        
        return nil
    }
}
