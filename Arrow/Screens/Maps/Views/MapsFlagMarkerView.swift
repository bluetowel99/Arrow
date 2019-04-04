
import UIKit

@IBDesignable class MapsFlagMarkerView: UIView {
    @IBOutlet weak var timeLabel: UILabel! {
        didSet {
            timeLabel.text = "12:00 AM"
        }
    }
    @IBOutlet weak var labelDecoration: UIView! {
        didSet {
            labelDecoration.layer.cornerRadius = 2
        }
    }
    
    class func instanceFor2DFromNib() -> MapsFlagMarkerView {
        return UINib(nibName: "MapsFlag2D", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! MapsFlagMarkerView
    }
    
    class func instanceFor3DFromNib() -> MapsFlagMarkerView {
        return UINib(nibName: "MapsFlag3D", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! MapsFlagMarkerView
    }
}
