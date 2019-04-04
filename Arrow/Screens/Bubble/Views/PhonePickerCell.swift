
import UIKit

class PhonePickerCell: UITableViewCell {
    
    static let estimatedRowHeight: CGFloat = 70.0
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    func setupCell(phoneLabel: String?, phoneNumber: String) {
        selectionStyle = .none
        
        titleLabel.text = phoneLabel
        valueLabel.text = phoneNumber
    }
    
    override func prepareForReuse() {
        titleLabel.text = nil
        valueLabel.text = nil
    }
    
}
