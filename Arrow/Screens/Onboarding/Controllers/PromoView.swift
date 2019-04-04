
import UIKit

class PromoView: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    
    static func instantiate(with image: UIImage?) -> PromoView {
        let instance = R.nib.promoView.firstView(owner: nil)!
        instance.imageView.image = image
        return instance
    }
    
}
