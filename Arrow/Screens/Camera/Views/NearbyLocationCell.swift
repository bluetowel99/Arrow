
import UIKit

class NearbyLocationCell: UITableViewCell {
    
    static let cellHeight: CGFloat = 90.0
    
    @IBOutlet weak var locationTitle: UILabel!
    @IBOutlet weak var locationAddress: UILabel!
    @IBOutlet weak var bookmarkButton: UIButton!

    @IBOutlet weak var titleLableHeight: NSLayoutConstraint!

    
    var isBookmarkable = false { didSet { updateBookmarkButton() } }
    var delegate: NearbyLocationCellDelegate?
    
    func setupCell(title: String?, address: String?, isBookmarkable: Bool = false) {
        selectionStyle = .none
        locationTitle.text = title
        locationAddress.text = address
        self.isBookmarkable = isBookmarkable
        titleLableHeight.constant = title == nil ? 0 : 22
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        locationTitle.text = nil
        locationAddress.text = nil
        updateBookmarkButton()
    }
    
    fileprivate func updateBookmarkButton() {
        bookmarkButton.isHidden = !isBookmarkable
    }
    
}

// MARK: - Event Handlers

extension NearbyLocationCell {
    
    @IBAction func bookmarkButtonPressed(sender: AnyObject) {
        delegate?.nearbyLocationCellDidPressBookmark(cell: self)
    }
    
}

// MARK: - NearbyLocationCellDelegate Definition

protocol NearbyLocationCellDelegate {
    func nearbyLocationCellDidPressBookmark(cell: NearbyLocationCell)
}
