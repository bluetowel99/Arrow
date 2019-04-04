
import Foundation
protocol MessagingHeaderTableViewCellDelegate {
    func didlikeMessage(row: Int)
}

class MessagingHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var heartImageView: UIImageView!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var usernameContainerView: UIView!

    var row: Int?
    var delegate: MessagingHeaderTableViewCellDelegate?

    var message: ARMessage?  {
        didSet {
            if let fullName = message?.displayName {
                var fullNameArr = fullName.components(separatedBy: " ")
                if fullNameArr.count >= 2 {
                    var personNameComponents = PersonNameComponents()
                    personNameComponents.givenName = fullNameArr[0]
                    personNameComponents.familyName = fullNameArr[1]
                    let personNameFormatter = PersonNameComponentsFormatter()
                    personNameFormatter.style = .abbreviated
                    initialsLabel.text = personNameFormatter.string(from: personNameComponents)
                }
            }
            if let likes = message?.likes {
                likeCountLabel.text = String(likes.count)
            }

        }
    }


    @IBAction func didTapLike(_ sender: Any) {
        if let row = self.row {
            self.delegate?.didlikeMessage(row: row)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        usernameContainerView.layer.cornerRadius = 17
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        likeCountLabel.text = "0"

    }

}
