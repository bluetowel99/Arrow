
import UIKit

final class ARDrawerDismissalAnimator: NSObject {}

// MARK: - UIViewControllerAnimatedTransitioning
extension ARDrawerDismissalAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromController = transitionContext.viewController(forKey: .from)!
        
        var frame = transitionContext.finalFrame(for: fromController)
        frame.origin.y = transitionContext.containerView.frame.size.height
        
        let animationDuration = transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: animationDuration, animations: {
            fromController.view.frame = frame
        }) { finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
