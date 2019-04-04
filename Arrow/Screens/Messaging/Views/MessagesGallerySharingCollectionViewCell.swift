
import UIKit

class MessagesGallerySharingCollectionViewCell: UICollectionViewCell {
    @IBOutlet var selectedBadgeImageView: UIImageView!
    @IBOutlet var imageView: UIImageView! {
        didSet {
            imageView.layer.borderColor = UIColor(red: 13.0 / 255.0, green: 139.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0).cgColor
        }
    }
    override var isSelected: Bool {
        didSet {
            guard let imageView = self.imageView else { return }
            if isSelected {
                imageView.layer.borderWidth = 5
                self.selectedBadgeImageView.isHidden = false
            } else {
                imageView.layer.borderWidth = 0
                self.selectedBadgeImageView.isHidden = true
            }
        }
    }
    
    var representedAssetIdentifier: String!
    
    var thumbnailImage: UIImage! {
        didSet {
            imageView.image = thumbnailImage
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        isSelected = false
    }
}
