
import UIKit

class ARMapPointOfInterest3DMarkerView: UIView {
    class func instanceFromNib(with poi: PointOfInterest) -> UIView {
        return UINib(nibName: "ARMapPointOfInterest3DMarkerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
}
