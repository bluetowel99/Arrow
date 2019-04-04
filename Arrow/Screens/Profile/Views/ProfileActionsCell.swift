
import UIKit

enum ProfileAction: Int {
    case bubbles = 0
    case friends
    case bookmarks
    
    var icon: UIImage? {
        switch self {
        case .bookmarks:
            return R.image.bookmarksRoundIcon()
        case .bubbles:
            return R.image.bubblesRoundIcon()
        case .friends:
            return R.image.friendsRoundIcon()
        }
    }
}

class ProfileActionsCell: UITableViewCell {
    
    @IBOutlet weak var bubblesButton: UIButton! { didSet { bubblesButton.tag = ProfileAction.bubbles.rawValue } }
    @IBOutlet weak var friendsButton: UIButton! { didSet { friendsButton.tag = ProfileAction.friends.rawValue } }
    @IBOutlet weak var bookmarksButton: UIButton! { didSet { bookmarksButton.tag = ProfileAction.bookmarks.rawValue } }
    
    var delegate: ProfileActionsCellDelegate?
    
}

// MARK: - Event Handler

extension ProfileActionsCell {
    
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        if let action = ProfileAction(rawValue: sender.tag) {
            delegate?.profileActionButtonPressed(action: action)
        }
    }
    
}

// MARK: - ProfileActionsCellDelegate Definition

protocol ProfileActionsCellDelegate {
    func profileActionButtonPressed(action: ProfileAction)
}
