
import UIKit

protocol MessagesMediaCollectionViewCellProtocol {
    func MessagesMediaCollectionViewCellDidTapDelete(row: Int)
    func MessagesMediaCollectionViewCellDidTapInfo(row: Int)
}

class MessagesMediaCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var infoButton: UIButton!
    var row: Int?

    var delegate:MessagesMediaCollectionViewCellProtocol?
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        infoButton.setImage(nil, for: .normal)
        
    }
    @IBAction func didTapInfoButton(_ sender: Any) {
        if let row = self.row {
            self.delegate?.MessagesMediaCollectionViewCellDidTapInfo(row: row)
        }
    }

    func setData(data: ARMediaInputData) {
        switch data.type {
        case .image:
            infoButton.setImage(R.image.addPhotoInfo(), for: .normal)
            imageView.image = data.image
            break
        case .video:
            infoButton.setImage(R.image.addVideoInfo(), for: .normal)
            imageView.image = data.image
            break
        default:
            imageView.image = nil
            infoButton.setImage(nil, for: .normal)
        }
    }
    @IBAction func deleteMediaAction(_ sender: Any) {
        if let row = self.row {
            self.delegate?.MessagesMediaCollectionViewCellDidTapDelete(row: row)
        }
    }
}

