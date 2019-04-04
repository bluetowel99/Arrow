
import UIKit

@IBDesignable class ARMapOther3DMarkerView: UIView {
    class func instanceFromNib() -> ARMapOther3DMarkerView {
        return UINib(nibName: "ARMapOther3DMarkerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ARMapOther3DMarkerView
    }
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var shadowImageView: UIImageView!
}
