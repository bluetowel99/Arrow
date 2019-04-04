
import UIKit

class SpecialsTableViewCell: UITableViewCell {

    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var howManyOrderedLabel: UILabel!
    @IBOutlet var flameImage: UIImageView!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var itemNameLabel: UILabel!
    @IBOutlet var itemDetailLabel: UILabel!
    @IBOutlet var itemImage: UIImageView!
    @IBOutlet var rateButton: UIButton!
    @IBOutlet var rateFlameView: UIView!
    @IBOutlet var ratingButton: UIButton!
    @IBOutlet var ratingImage: UIImageView!
    @IBOutlet var rateView: UIView!
    @IBOutlet var photoButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        rateFlameView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
