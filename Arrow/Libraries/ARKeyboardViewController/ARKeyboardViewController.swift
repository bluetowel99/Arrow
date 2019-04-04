
import UIKit

/// Abstract class for UIViewControllers with scrolling keyboard support.

class ARKeyboardViewController: ARViewController {
    
    private typealias KeyboardAnimationInfo = (beginFrame: CGRect, endFrame: CGRect, duration: TimeInterval, curve: UIViewAnimationOptions)
    
    @IBOutlet weak var scrollView: UIScrollView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addKeyboardObservers()
    }
    
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(ARKeyboardViewController.keyboardWillShow(_:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ARKeyboardViewController.keyboardWillHide(_:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    private func getKeyboardInfo(from notification: NSNotification) -> KeyboardAnimationInfo {
        var userInfo = notification.userInfo!
        let beginFrame: CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let endFrame: CGRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let curveValue = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uintValue << 16
        let animationCurve = UIViewAnimationOptions.init(rawValue: curveValue)
        
        return (beginFrame: beginFrame, endFrame: endFrame, duration: animationDuration, curve: animationCurve)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        let (_, endFrame, duration, curve) = getKeyboardInfo(from: notification)
        keyboardHeightWillChange(from: 0.0, to: endFrame.size.height, animationDuration: duration, animationCurve: curve)
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        let (beginFrame, _, duration, curve) = getKeyboardInfo(from: notification)
        keyboardHeightWillChange(from: beginFrame.size.height, to: 0.0, animationDuration: duration, animationCurve: curve)
    }
    
    func keyboardHeightWillChange(from initHeight: CGFloat, to endHeight: CGFloat, animationDuration: TimeInterval, animationCurve: UIViewAnimationOptions) {
        guard var contentInset = self.scrollView?.contentInset else {
            return
        }
        
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: animationCurve, animations: {
            contentInset.bottom = endHeight
            self.scrollView?.contentInset = contentInset
            self.scrollView?.scrollIndicatorInsets = contentInset
        }, completion: nil)
    }
    
}
