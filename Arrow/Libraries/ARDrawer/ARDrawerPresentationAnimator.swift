
import UIKit

final class ARDrawerPresentationAnimator: NSObject {}

// MARK: - UIViewControllerAnimatedTransitioning
extension ARDrawerPresentationAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toController = transitionContext.viewController(forKey: .to)!
        
        transitionContext.containerView.addSubview(toController.view)
        
        let presentedFrame = transitionContext.finalFrame(for: toController)
        var dismissedFrame = presentedFrame
        dismissedFrame.origin.y = transitionContext.containerView.frame.size.height
        
        let initialFrame = dismissedFrame
        let finalFrame = presentedFrame
        
        let animationDuration = transitionDuration(using: transitionContext)
        toController.view.frame = initialFrame
        UIView.animate(withDuration: animationDuration, animations: {
            toController.view.frame = finalFrame
        }) { finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
