
import UIKit

final class ProfileSectionHeader: UITableViewHeaderFooterView {
    
    static var reuseIdentifier: String {
        return "ProfileSectionHeader"
    }
    
    static var height: CGFloat = 40.0

    @IBOutlet weak var separatorLine: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var showMoreButton: UIButton!
    
    func setupHeader(title: String, showMore: Bool) {
        titleLabel.text = title
        showMoreButton.isHidden = !showMore
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        titleLabel.isHidden = false
        showMoreButton.isHidden = false
        separatorLine.isHidden = false
    }
    
}

// MARK: - Event Handlers

extension ProfileSectionHeader {
    
    @IBAction func showMoreButtonPressed(_ sender: AnyObject) {
        // TODO(kia): Notify that button has been pressed.
    }
    
}
