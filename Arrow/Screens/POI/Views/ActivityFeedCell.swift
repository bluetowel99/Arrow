
import UIKit

// MARK: - ActivityFeedCellDelegate

protocol ActivityFeedCellDelegate {
    func upVoteButtonPressed(cell: ActivityFeedCell, activityFeed: ARActivityFeed?, indexPath: IndexPath?)
    func downVoteButtonPressed(cell: ActivityFeedCell, activityFeed: ARActivityFeed?, indexPath: IndexPath?)
    func openImage(imageUrl: URL?)
}

class ActivityFeedCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var upVoteActionButton: UIButton!
    @IBOutlet weak var downVoteActionButton: UIButton!
    @IBOutlet weak var voteLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var capsuleView: CapsuleView!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var ratingStackView: UIStackView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var experienceLabel: UILabel!
    @IBOutlet weak var foodLabel: UILabel!
    @IBOutlet weak var atmosphereLabel: UILabel!
    @IBOutlet weak var serviceLabel: UILabel!
    
    fileprivate(set) var activityFeed: ARActivityFeed?
    fileprivate(set) var indexPath: IndexPath?
    var delegate: ActivityFeedCellDelegate?
    
    func setupCell(activityFeed: ARActivityFeed?, indexPath: IndexPath) -> Void {
        selectionStyle = .none
        self.activityFeed = activityFeed
        self.indexPath = indexPath
        updateView()
    }
    
    func setupTopCell(images: [UIImage]) -> Void {
        selectionStyle = .none

        for subview in imageScrollView.subviews {
            subview.removeFromSuperview()
        }
        if images.count != 0 {
            imageScrollView.backgroundColor = .white
            var imageWidth: CGFloat = imageScrollView.frame.size.width
            if images.count == 1 {
                imageWidth = imageScrollView.frame.size.width
                scrollViewHeight.constant = imageScrollView.frame.size.width * ARConstants.ImageView.moreHalfWidth
            }
            else if images.count == 2 {
                imageWidth = (imageScrollView.frame.size.width - ARConstants.ImageView.seperation) * ARConstants.ImageView.halfWidth
                scrollViewHeight.constant = imageScrollView.frame.size.width * ARConstants.ImageView.halfWidth
            }
            else {
                imageWidth = imageScrollView.frame.size.width * ARConstants.ImageView.moreHeight
                scrollViewHeight.constant = imageScrollView.frame.size.width * ARConstants.ImageView.lessHalfWidth
            }
            for i in 0..<images.count {
                let imageView = Bundle.main.loadNibNamed("ImageView", owner: self, options: nil)?.first as? ImageView
                imageView?.frame = CGRect(x: CGFloat(i) * (imageWidth + ARConstants.ImageView.seperation), y: 0, width: imageWidth, height: imageScrollView.frame.size.height)
                imageView?.setupImage(image: images[i])
                imageScrollView.addSubview(imageView!)
            }
            imageScrollView.contentSize = CGSize(width: imageWidth * CGFloat(images.count) + ARConstants.ImageView.seperation * (CGFloat(images.count) - 1), height: scrollViewHeight.constant)
        }
        else {
            imageScrollView.backgroundColor = .clear
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        activityFeed = nil
    }
   
    @IBAction func upVoteButtonPressed(_ sender: UIButton) {
        delegate?.upVoteButtonPressed(cell: self, activityFeed: activityFeed, indexPath: indexPath)
    }
    
    @IBAction func downVoteButtonPressed(_ sender: UIButton) {
        delegate?.downVoteButtonPressed(cell: self, activityFeed: activityFeed, indexPath: indexPath)
    }
}

// MARK: - UI Helpers

extension ActivityFeedCell {
    
    fileprivate func updateView() {
        if capsuleView != nil {
            capsuleView.setupView()
        }
        if userImageView != nil {
            userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        }
        
        nameLabel.text = String(format: "%@ %@", activityFeed?.createdBy?.firstName ?? "", activityFeed?.createdBy?.lastName ?? "")
        
        if let time = activityFeed?.time {
            timeLabel.text = timeAgoSinceDate(date: time, numericDates: false)
        }
        
        if let comment = activityFeed?.comment {
            commentLabel.text = comment
        }

        if let voteCount = activityFeed?.voteCount {
            if voteCount > 0 {
                voteLabel.text = String(format: "+%d", voteCount)
            }
            else {
                voteLabel.text = String(format: "%d", voteCount)
            }
        }
        
        if let pictureUrl = activityFeed?.createdBy?.pictureUrl {
            userImageView.setImage(from: pictureUrl) {                
            }
        }
        
        let count = activityFeed?.images.count ?? 0
        if count != 0 {
            for subview in imageScrollView.subviews {
                subview.removeFromSuperview()
            }
            var imageWidth: CGFloat = imageScrollView.frame.size.width
            if count == 1 {
                imageWidth = imageScrollView.frame.size.width
                scrollViewHeight.constant = imageScrollView.frame.size.width * ARConstants.ImageView.moreHalfWidth
            }
            else if count == 2 {
                imageWidth = (imageScrollView.frame.size.width - ARConstants.ImageView.seperation) * ARConstants.ImageView.halfWidth
                scrollViewHeight.constant = imageScrollView.frame.size.width * ARConstants.ImageView.halfWidth
            }
            else {
                imageWidth = imageScrollView.frame.size.width * ARConstants.ImageView.moreHeight
                scrollViewHeight.constant = imageScrollView.frame.size.width * ARConstants.ImageView.lessHalfWidth
            }
            for i in 0..<count {
                let imageView = Bundle.main.loadNibNamed("ImageView", owner: self, options: nil)?.first as? ImageView
                imageView?.frame = CGRect(x: CGFloat(i) * (imageWidth + ARConstants.ImageView.seperation), y: 0, width: imageWidth, height: imageScrollView.frame.size.height)
                imageView?.setupView(imageUrl: activityFeed?.images[i])
                imageView?.delegate = self
                imageScrollView.addSubview(imageView!)
            }
            imageScrollView.contentSize = CGSize(width: imageWidth * CGFloat(count) + ARConstants.ImageView.seperation * (CGFloat(count) - 1), height: scrollViewHeight.constant)
        }
        
        if let rating = activityFeed?.rating {
            let _ = ratingStackView.arrangedSubviews.enumerated().map { index, element in
                guard let flameIcon = element as? UIImageView else { return }
                let index = Float(index + 1)
                let rating: Float = (rating.atmosphere! + rating.experience! + rating.food! + rating.service!) / 4
                
                if rating >= index {
                    flameIcon.image = R.image.ratingFlameFilled()
                } else if (index - rating) < 0.5 {
                    flameIcon.image = R.image.ratingFlameHalf()
                } else {
                    flameIcon.image = R.image.ratingFlameEmpty()
                }
            }
            experienceLabel.text = String(format: "%d", (Int)(rating.experience!))
            foodLabel.text = String(format: "%d", (Int)(rating.food!))
            serviceLabel.text = String(format: "%d", (Int)(rating.service!))
            atmosphereLabel.text = String(format: "%d", (Int)(rating.atmosphere!))
            
            ratingLabel.text = activityFeed?.name
        }
        if activityFeed?.isVoted == true {
            upVoteActionButton.isSelected = (activityFeed?.upvote)!
            downVoteActionButton.isSelected = !(activityFeed?.upvote)!
        }
        else {
            upVoteActionButton.isSelected = false
            downVoteActionButton.isSelected = false
        }
        layoutIfNeeded()
    }
    
    func timeAgoSinceDate(date:Date, numericDates:Bool) -> String {
        let calendar = NSCalendar.current
        let now = NSDate()
        let earliest = now.earlierDate(date)
        let latest = (earliest == now as Date) ? date : now as Date
        let components = calendar.dateComponents(Set<Calendar.Component>(arrayLiteral: .minute, .hour, .day, .weekOfYear, .month, .year, .second), from: earliest, to: latest as Date)
        
        if (components.year! >= 2) {
            return "\(components.year!) years ago"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 year ago"
            } else {
                return "Last year"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) months ago"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1 month ago"
            } else {
                return "Last month"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) weeks ago"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1 week ago"
            } else {
                return "Last week"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) days ago"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1 day ago"
            } else {
                return "Yesterday"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) hours ago"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1 hour ago"
            } else {
                return "An hour ago"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!) minutes ago"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1 minute ago"
            } else {
                return "A minute ago"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!) seconds ago"
        } else {
            return "Just now"
        }
    }
}

extension ActivityFeedCell: ImageViewDelegate {
    func openImage(imageUrl: URL?) {
        delegate?.openImage(imageUrl: imageUrl)
    }
}
