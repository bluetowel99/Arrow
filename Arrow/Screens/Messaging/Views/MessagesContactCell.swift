
import Foundation


class MessagesContactCell: UITableViewCell {

    enum Mode {
        case none
        case checked
        case unchecked
        case deleteButton
    }

    static let rowHeight: CGFloat = 70.0

    @IBOutlet weak var thumbnailView: UIView!
    @IBOutlet weak var thumbnailInitialsLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var actionImageView: UIImageView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var separatorLine: UIView!
    @IBOutlet weak var checkedIcon: UIImageView!


    var mode: Mode = .none {
        didSet {
            updateCell(to: mode)
        }
    }

    private(set) var person: ARPerson!
    var delegate: BubbleMemberCellDelegate?

    func setupCell(person: ARPerson) {
        selectionStyle = .none

        self.person = person

        if let thumbnail = person.thumbnail {
            thumbnailImageView.image = thumbnail
        } else if let picUrl = person.pictureUrl {
            thumbnailImageView.setImage(from: picUrl)
        } else {
            thumbnailImageView.isHidden = true
            thumbnailInitialsLabel.text = person.displayName(style: .abbreviated)
        }

        nameLabel.text = person.displayName()
        updateCell(to: mode)
    }

    func hideSeparatorLine() {
        separatorLine.isHidden = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        thumbnailView.layer.cornerRadius = thumbnailImageView.frame.height / 2.0
    }

    override func prepareForReuse() {
        person = nil
        thumbnailInitialsLabel.isHidden = false
        thumbnailInitialsLabel.text = nil
        thumbnailImageView.isHidden = false
        thumbnailImageView.image = nil
        nameLabel.text = nil
        separatorLine.isHidden = false
        updateCell(to: mode)
    }

}

// MARK: - Private Helpers

extension MessagesContactCell {

    fileprivate func updateCell(to mode: Mode) {
        var textColor = R.color.arrowColors.marineBlue()

        switch mode {
        case .none:
            break
        case .checked:
            checkedIcon.image = R.image.contactSelected()
        case .unchecked:
            textColor = R.color.arrowColors.hathiGray()
            checkedIcon.image = R.image.emptyOval()
        default:
            break
        }

        nameLabel.textColor = textColor
        //actionImageView.image = actionImage
        //actionButton.isUserInteractionEnabled = enableActionButton
    }

}
