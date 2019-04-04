
import UIKit

final class MessagingInboxTableViewCell: UITableViewCell {
    
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var previewLabel: UILabel!
    @IBOutlet weak var unreadImageView: UIImageView!
    @IBOutlet weak var dividerView: ARDividerView!
    @IBOutlet weak var threadImageView: UIImageView!
    @IBOutlet weak var threadInitials: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        threadInitials.layer.cornerRadius = 27.5
        threadInitials.layer.masksToBounds = true
    }
    
    func configure()
    {
        var fullNameArr = titleLabel.text?.components(separatedBy: " ")
        if (fullNameArr?.count)! >= 1 {
            var personNameComponents = PersonNameComponents()
            personNameComponents.givenName = fullNameArr?[0]
            if (fullNameArr?.count)! >= 2 {
                personNameComponents.familyName = fullNameArr?[1]
            } else {
                personNameComponents.familyName = ""
            }
            let personNameFormatter = PersonNameComponentsFormatter()
            personNameFormatter.style = .abbreviated
            threadInitials.text = personNameFormatter.string(from: personNameComponents)
        }
    }
}
