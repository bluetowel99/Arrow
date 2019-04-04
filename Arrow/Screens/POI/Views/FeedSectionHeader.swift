
import Foundation

protocol FeedSectionHeaderDelegate {
    func feedUpdatePressed(status: Bool)
}

final class FeedSectionHeader: UITableViewHeaderFooterView {
    
    static var reuseIdentifier: String {
        return "FeedSectionHeader"
    }
    
    static var height: CGFloat = 33.0
    var delegate: FeedSectionHeaderDelegate?
    
    @IBOutlet weak var newestActionButton: UIButton!
    @IBOutlet weak var topeVotedActionButton: UIButton!
    @IBOutlet weak var newestLineImage: UIImageView!
    @IBOutlet weak var topVotedLineImage: UIImageView!
    
    func setupHeader(status: Bool) {
        contentView.backgroundColor = .white
        if status {
            newestActionButton.setTitleColor(UIColor.black, for: .normal)
            newestLineImage.alpha = 1
            topeVotedActionButton.setTitleColor(UIColor.lightGray, for: .normal)
            topVotedLineImage.alpha = 0
        }
        else {
            newestActionButton.setTitleColor(UIColor.lightGray, for: .normal)
            newestLineImage.alpha = 0
            topeVotedActionButton.setTitleColor(UIColor.black, for: .normal)
            topVotedLineImage.alpha = 1
        }
    }
    
    @IBAction func newestActionButton(_ sender: Any) {
        delegate?.feedUpdatePressed(status: true)
    }
    
    @IBAction func topVotedActionButton(_ sender: Any) {
        delegate?.feedUpdatePressed(status: false)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
