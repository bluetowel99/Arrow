
import UIKit
import FirebaseStorage

protocol MessagingMediaTableViewCellDelegate {
    func didTapMedia(message: ARMessage, index: Int?)
}

final class MessagingMediaTableViewCell: UITableViewCell {

    @IBOutlet weak var mediaCollectionView: UICollectionView!


    var delegate: MessagingMediaTableViewCellDelegate?

    var message: ARMessage? {
        didSet {
            mediaCollectionView.reloadData()
        }
    }
    var gsurl: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.mediaCollectionView.delegate = self
        self.mediaCollectionView.dataSource = self
        mediaCollectionView.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.message = nil
        mediaCollectionView.reloadData()
    }
}

extension MessagingMediaTableViewCell: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return message?.media?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MessagingMediaItemCollectionViewCell", for: indexPath) as? MessagingMediaItemCollectionViewCell
            else { fatalError("unexpected cell in collection view") }
        cell.imageView.image = nil
        cell.row = indexPath.row
        if let media = message?.media?[indexPath.row], let gsurl = media.url, let row = cell.row {
            if let image = UIImage.cachedImage(forKey: gsurl.absoluteString) {
                cell.imageView.image = image
            } else {
                Storage.storage().reference(forURL: gsurl.absoluteString).downloadURL(completion: {(url, error) in
                    guard let url = url else {
                        return
                    }
                    print(url.absoluteString)
                    if row == cell.row  {
                        cell.imageView.setImage(from: url,key: gsurl.absoluteString, placeholder: nil,completion: nil)
                    }
                })
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        return CGSize(width: 143.0, height: 300.0)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let message = self.message {
            self.delegate?.didTapMedia(message: message, index: indexPath.row)
        }

    }
}

extension MessagingMediaTableViewCell: UICollectionViewDelegate {

}
