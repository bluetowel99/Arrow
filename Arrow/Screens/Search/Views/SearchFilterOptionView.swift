
import UIKit

class SearchFilterOptionView: ARControl {
    
    override var kNib: UINib? { return R.nib.searchFilterOptionView() }
    
    static var cellHeight: CGFloat = 50.0
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var separatorLineView: UIView!
    
    func setupView(title: String?, isSelected: Bool, isLastRow: Bool) -> Void {
        titleLabel.text = title
        iconImageView.image = isSelected ? R.image.settingOptionSwitchOn() : R.image.settingOptionSwitchOff()
        separatorLineView.isHidden = isLastRow
    }
    
}
