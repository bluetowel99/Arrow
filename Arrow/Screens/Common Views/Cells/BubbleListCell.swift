

import UIKit

class BubbleListCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var recentActionLabel: UILabel!
    @IBOutlet weak var unreadIconImageView: UIImageView!
    
    func setup(bubble: ARBubble) {
        selectionStyle = .none
        if let pic = bubble.picture {
            thumbnailImageView.image = pic
        } else if let picUrl = bubble.pictureUrl {
            thumbnailImageView.setImage(from: picUrl)
        } else {
            thumbnailImageView.image = #imageLiteral(resourceName: "BubblesRoundIcon")
        }

        titleLabel.text = bubble.title
        recentActionLabel.text = bubble.recentActivity?.type.title
        
        if let timeStamp = bubble.recentActivity?.timeStamp {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = Calendar.current.isDateInToday(timeStamp) ? "h:mma" : "MMM d, yyyy"
            timestampLabel.text = dateFormatter.string(from: timeStamp)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = #imageLiteral(resourceName: "BubblesRoundIcon")
        titleLabel.text = nil
        timestampLabel.text = nil
        recentActionLabel.text = nil
        unreadIconImageView.isHidden = true
    }
    
}
