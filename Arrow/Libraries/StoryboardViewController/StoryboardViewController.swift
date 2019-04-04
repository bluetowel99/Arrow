
import UIKit

/// A protocol facilitating instantiation of storyboard-backed view controllers.

protocol StoryboardViewController {
    
    /// Storyboard where the view controller resides.
    static var kStoryboard: UIStoryboard { get }
    
    /// Storyboard ID of the view controller, assigned using IB.
    ///
    /// Set to nil if view controller is storyboard's initial view controller.
    static var kStoryboardIdentifier: String? { get }
    
    /// Instantiates the storyboard-backed view controller.
    static func instantiate() -> Self
    
}

// MARK: - Protocol Implementation For UIViewController

extension StoryboardViewController where Self: UIViewController {
    
    static func instantiate() -> Self {
        if let storyboardId = kStoryboardIdentifier {
            return kStoryboard.instantiateViewController(withIdentifier: storyboardId) as! Self
        } else {
            return kStoryboard.instantiateInitialViewController() as! Self
        }
    }
    
}
