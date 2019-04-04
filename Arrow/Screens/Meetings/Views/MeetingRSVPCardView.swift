
import UIKit

class MeetingRSVPCardView: UIView {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var cardContainer: UIView!
    override func awakeFromNib() {
        self.mainView.layer.cornerRadius = 8.0
        self.mainView.layer.masksToBounds = true
    }
    @IBAction func closeAction(_ sender: Any) {
        self.removeFromSuperview()
    }
    class func instanceFromNib() -> MeetingRSVPCardView {
        return UINib(nibName: "MeetingRSVPCardView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! MeetingRSVPCardView
    }
}
