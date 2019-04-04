
import CoreLocation
import UIKit

class SettingOptionCell: UITableViewCell {
    
    static var cellHeight: CGFloat = 60.0
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var separatorLineView: UIView!
    
    func setupCell(option: ARSettingOption, isLastRow: Bool) -> Void {
        selectionStyle = .none
        titleLabel.text = option.title
        iconImageView.image = option.type.icon
        separatorLineView.isHidden = isLastRow
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        iconImageView.image = nil
        separatorLineView.isHidden = false
    }
    
}
