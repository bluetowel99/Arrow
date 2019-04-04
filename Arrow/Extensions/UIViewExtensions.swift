
import UIKit

// MARK: - NSLayoutConstraint Extensions

extension UIView {
    
    func setViewConstraints(equalTo view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let pinTop = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal,
                                        toItem: self, attribute: .top, multiplier: 1.0, constant: 0)
        let pinBottom = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal,
                                           toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0)
        let pinLeft = NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal,
                                         toItem: self, attribute: .left, multiplier: 1.0, constant: 0)
        let pinRight = NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal,
                                          toItem: self, attribute: .right, multiplier: 1.0, constant: 0)
        
        self.addConstraints([pinTop, pinBottom, pinLeft, pinRight])
    }
    
}
