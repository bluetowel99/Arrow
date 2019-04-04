
import UIKit

class ARDrawerInteractiveTransition: UIPercentDrivenInteractiveTransition {
    var drawer: ARDrawer
	var transitionContext: UIViewControllerContextTransitioning?
	var panGestureRecognizer: UIPanGestureRecognizer
	fileprivate var shouldComplete: Bool = false
    
	init(with drawer: ARDrawer) {
        self.drawer = drawer
		self.panGestureRecognizer = UIPanGestureRecognizer()
		
		super.init()
		
		self.panGestureRecognizer.addTarget(self, action: #selector(onPan))
		drawer.dragView.addGestureRecognizer(panGestureRecognizer)
	}
	
	override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
		super.startInteractiveTransition(transitionContext)
		self.transitionContext = transitionContext
	}
	
	override var completionSpeed: CGFloat {
		get {
			return 1.0 - self.percentComplete
		}
		set {}
	}
    
    @objc func onPan(pan: UIPanGestureRecognizer) -> Void {
        
        switch pan.state {
        case .began:
            drawer.dismiss(with: true)
            break
            
        case .changed:
            guard let context = self.transitionContext else { return }
            let containerView = context.containerView
            let locationInContainer = pan.translation(in: pan.view?.superview)
            let containerViewHeight = Float(containerView.bounds.height)
            let threshold: Float = 0.4
            var percent = Float(locationInContainer.y) / containerViewHeight
            
            percent = fmaxf(percent, 0.0)
            percent = fminf(percent, 1.0)
            update(CGFloat(percent))
            
            shouldComplete = percent > threshold
            break
            
        case .ended, .cancelled:
            if shouldComplete {
                finish()
            } else {
                cancel()
            }
            
            break
            
        default:
            cancel()
            
            break
        }

    }

}
