
import UIKit

protocol ARSearchCategory {
    
    var tintColor: UIColor { get }
    var title: String? { get }
    var headerTitle: String? { get }
    var searchQuery: String? { get }
    
    func image(inBW: Bool) -> UIImage?
    
}
