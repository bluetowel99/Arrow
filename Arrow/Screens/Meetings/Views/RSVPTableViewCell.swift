
import UIKit

class RSVPTableViewCell: UITableViewCell {

    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var containerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    override func prepareForReuse() {
        personImageView.image = nil
        
    }

}
