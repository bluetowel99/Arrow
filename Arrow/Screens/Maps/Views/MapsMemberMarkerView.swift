
import UIKit

class MapsMemberMarkerView: UIView {
    class func instanceFromNib() -> MapsMemberMarkerView {
        return UINib(nibName: "MapsMemberMarkerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! MapsMemberMarkerView
    }
    var person: ARPerson? {
        didSet {
            guard let person = person else { return }
            if(person.pictureUrl != nil) {
                iconView.setImage(from: person.pictureUrl!, completion: {
                    self.iconView.layer.cornerRadius = self.iconView.frame.size.width / 2
                    self.iconView.clipsToBounds = true
                })
            }
        }
    }
    @IBOutlet weak var iconView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 22
    }
}
