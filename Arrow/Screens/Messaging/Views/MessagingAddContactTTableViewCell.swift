
import Foundation

protocol MessagingAddContactTTableViewCellDelegate {
    func didTapDelete(row: Int)
    func didTapCall(row: Int)
    func didTapArrow(row: Int)
}
class MessagingAddContactTTableViewCell: UITableViewCell {

    @IBOutlet weak var deleteContact: UIButton!
    @IBOutlet weak var arrowIcon: UIButton!
    @IBOutlet weak var callIcon: UIButton!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var thumbnailView: UIView!
    @IBOutlet weak var thumbnailInitialsLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!

    private(set) var person: ARPerson!
    var delegate: MessagingAddContactTTableViewCellDelegate?
    var row: Int?
    func setUser(user: ARPerson) {
        userLabel.text = user.displayName()
        self.person = user
        if let thumbnail = person.thumbnail {
            thumbnailImageView.image = thumbnail
        } else if let picUrl = person.pictureUrl {
            thumbnailImageView.setImage(from: picUrl)
        } else {
            thumbnailImageView.isHidden = true
            thumbnailInitialsLabel.text = person.displayName(style: .abbreviated)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        thumbnailView.layer.cornerRadius = thumbnailImageView.frame.height / 2.0
    }

    override func prepareForReuse() {
        person = nil
        thumbnailInitialsLabel.text = nil
        thumbnailImageView.isHidden = false
        thumbnailImageView.image = nil
        userLabel.text = nil
    }

    @IBAction func deleteAction(_ sender: Any) {
        if let row = row {
            self.delegate?.didTapDelete(row: row)
        }
    }

    @IBAction func arrowAction(_ sender: Any) {
        if let row = row {
            self.delegate?.didTapArrow(row: row)
        }
    }
    @IBAction func callAction(_ sender: Any) {
        if let row = row {
            self.delegate?.didTapCall(row: row)
        }
    }


}
