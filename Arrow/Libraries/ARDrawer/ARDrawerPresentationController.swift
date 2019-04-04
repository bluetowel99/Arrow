
import UIKit

final class ARDrawerPresentationController: UIPresentationController {
    var isMaximized: Bool = false
    
    override var frameOfPresentedViewInContainerView: CGRect {
        var frame: CGRect = .zero
        frame.size = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerView!.bounds.size)
        frame.origin.y = containerView!.frame.height - frame.height
        return frame
    }
    
    override func containerViewWillLayoutSubviews() {
        if isMaximized {
            guard let containerView = self.containerView else { return }
            presentedView?.frame = containerView.frame
        } else {
            presentedView?.frame = frameOfPresentedViewInContainerView
        }
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        if isMaximized {
            return parentSize
        }
        
        return CGSize(width: parentSize.width, height: parentSize.height * 0.8)
    }
    
    func maximize() {
        if let presentedView = presentedView, let containerView = self.containerView {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                presentedView.frame = containerView.frame
                self.isMaximized = true
            }, completion: nil)
        }
    }
    
    func miniumize() {
        if let presentedView = presentedView, let containerView = self.containerView {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                presentedView.frame = containerView.frame
                self.isMaximized = true
            }, completion: nil)
        }
    }
}
