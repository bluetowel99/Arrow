
import UIKit

// MARK: - ProfileInfoCell Definition

protocol ProfileInfoCellDelegate {
    func settingsButtonPressed()
}

class ProfileInfoCell: UITableViewCell {
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var thumbnailContainerView: UIView!
    @IBOutlet weak var thumbnailLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var litPointsLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    var delegate: ProfileInfoCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        thumbnailLabel.layer.cornerRadius = 50
        thumbnailLabel.layer.masksToBounds = true
    }
    
    func setupCell(person: ARPerson) -> Void {
        if let url = person.pictureUrl {
            photoImageView.setImage(from: url, completion: {
                self.photoImageView.layer.cornerRadius = self.photoImageView.frame.size.width / 2
                self.photoImageView.clipsToBounds = true
            })
        }
        
        thumbnailLabel.text = person.displayName(style: .abbreviated)
        
        if let points = person.litPoints {
            litPointsLabel.text = NumberFormatter.localizedString(from: NSNumber(integerLiteral: points), number: .decimal)
        }
        
        nameLabel.text = person.displayName(style: .long)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = nil
        litPointsLabel.text = nil
        nameLabel.text = nil
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        thumbnailContainerView.layer.cornerRadius = thumbnailContainerView.frame.width / 2.0
    }
    
}

// MARK: - Event Handlers

extension ProfileInfoCell {
    
    @IBAction func settingsButtonPressed(_ sender: AnyObject) {
        delegate?.settingsButtonPressed()
    }
    
}
