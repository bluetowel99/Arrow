
import UIKit

/// A protocol facilitating instantiation of nib-backed view controllers.

protocol NibViewController {
    
    /// Nib where the view controller resides.
    static var kNib: UINib { get }
    
    /// Instantiates the nib-backed view controller.
    static func instantiate() -> Self
    
}

// MARK: - Protocol Implementation For UIViewController

extension NibViewController where Self: UIViewController {
    
    static func instantiate() -> Self {
        return kNib.instantiate(withOwner: nil, options: nil).first as! Self
    }
    
}
